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
            raise "Theme file does not exist for theme \"#{theme_name}\": \"#{color_theme_path}\""
          end

          delete(color_theme: color_theme)
        end

        def delete(color_theme:)
          return false unless exist?(theme_name: color_theme.theme_name)

          color_theme_path = color_theme_path(theme_name: color_theme.theme_name)
          File.delete(color_theme_path)

          true
        end

        def exist?(theme_name:)
          color_theme_path = color_theme_path(theme_name: theme_name)
          File.exist?(color_theme_path)
        end

        def find(theme_name:)
          color_theme_path = color_theme_path(theme_name: theme_name)
          raise "Color theme does not exist: \"#{theme_name}\"" unless exist?(theme_name: theme_name)

          color_theme_hash = Psych.safe_load(File.read(color_theme_path), [Symbol])
          new(theme_name: theme_name, theme_hash: color_theme_hash)
        end

        def find_or_create(theme_name:)
          return find(theme_name: theme_name) if exist?(theme_name: theme_name)

          theme_description = "#{theme_name.capitalize} theme"
          theme_hash = self::DEFAULT_THEME.merge(description: theme_description)
          new(theme_name: theme_name, theme_hash: theme_hash)
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

        def color_theme_file(theme_name:)
          # Basicall returns the color theme name for now, but let's keep this
          # in case we want to add an extension later on.
          theme_name
        end

        def color_theme_path(theme_name:)
          File.join(color_theme_folder, color_theme_file(theme_name: theme_name))
        end

        def color_theme_folder
          configuration.themes_folder
        end

        private

        def configuration
          @configuration ||= Models::Configuration.current_or_default
        end
      end
    end
  end
end
