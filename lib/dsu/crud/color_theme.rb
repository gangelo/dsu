# frozen_string_literal: true

require 'psych'
require_relative '../models/configuration'

module Dsu
  module Crud
    module ColorTheme
      class << self
        def included(base)
          base.extend(ClassMethods)
        end
      end

      def delete
        self.class.delete(theme_name: theme_name)
      end

      def delete!
        self.class.delete!(theme_name: theme_name)
      end

      def exist?
        self.class.exist?(theme_name: theme_name)
      end

      def save
        self.class.save(color_theme: self)
      end

      def save!
        self.class.save!(color_theme: self)
      end

      module ClassMethods
        def delete!(theme_name:)
          unless exist?(theme_name: theme_name)
            raise "Theme file does not exist for theme \"#{theme_name}\": " \
                  "\"#{color_theme_path(theme_name: theme_name)}\""
          end

          delete(theme_name: theme_name)
        end

        def delete(theme_name:)
          return false unless exist?(theme_name: theme_name)

          color_theme_path = color_theme_path(theme_name: theme_name)
          File.delete(color_theme_path)

          reset_default_configuration_color_theme_if!(deleted_theme_name: theme_name)

          true
        end

        def exist?(theme_name:)
          color_theme_path = color_theme_path(theme_name: theme_name)
          File.exist?(color_theme_path)
        end

        def find(theme_name:)
          raise "Color theme does not exist: \"#{theme_name}\"" unless exist?(theme_name: theme_name)

          color_theme_path = color_theme_path(theme_name: theme_name)
          color_theme_hash = Psych.safe_load(File.read(color_theme_path), [Symbol])
          new(theme_name: theme_name, theme_hash: color_theme_hash)
        end

        def find_or_create(theme_name:)
          return find(theme_name: theme_name) if exist?(theme_name: theme_name)

          new(theme_name: theme_name).save!
        end

        def find_or_initialize(theme_name:)
          return find(theme_name: theme_name) if exist?(theme_name: theme_name)

          new(theme_name: theme_name)
        end

        def save(color_theme:)
          return false unless color_theme.valid?

          color_theme_path = color_theme_path(theme_name: color_theme.theme_name)
          File.write(color_theme_path, Psych.dump(color_theme.to_h))

          true
        end

        def save!(color_theme:)
          color_theme.validate!

          save(color_theme: color_theme)

          color_theme
        end

        def hash_for(theme_name:)
          raise "Color theme does not exist: \"#{theme_name}\"" unless exist?(theme_name: theme_name)

          # Do not load the class because it is possible
          color_theme_path = color_theme_path(theme_name: theme_name)
          Psych.safe_load(File.read(color_theme_path), [Symbol])
        end

        def color_theme_file(theme_name:)
          # Basicall returns the color theme name for now, but let's keep this
          # in case we want to add a file extension later on.
          theme_name
        end

        def color_theme_path(theme_name:)
          File.join(color_theme_folder, color_theme_file(theme_name: theme_name))
        end

        def color_theme_folder
          color_theme_folder = configuration.themes_folder
          FileUtils.mkdir_p(color_theme_folder)
          color_theme_folder
        end

        private

        # If the color theme is deleted (deleted_theme_name) and the current
        # theme_name in the configuration is the same as the deleted theme,
        # we need to reset the configuration theme to the default theme.
        def reset_default_configuration_color_theme_if!(deleted_theme_name:)
          config = configuration
          return if config.theme_name == Models::ColorTheme::DEFAULT_THEME_NAME
          return unless config.theme_name == deleted_theme_name
          return unless config.exist?

          config.theme_name = Models::ColorTheme::DEFAULT_THEME_NAME
          config.save!
        end

        def configuration
          # NOTE: Do not memoize this, as it will cause issues if
          # the configuration is updated (e.g. themes_folder,
          # entries_folder, etc.); in this case, a memoized
          # configuration would not reflect the updated values.
          Models::Configuration.current_or_default
        end
      end
    end
  end
end
