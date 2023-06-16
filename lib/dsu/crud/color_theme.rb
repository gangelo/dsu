# frozen_string_literal: true

require 'fileutils'
require 'psych'
require_relative '../models/configuration'
require_relative '../support/fileable'

module Dsu
  module Crud
    module ColorTheme
      include Support::Fileable

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
        def safe_create_unless_exists!
          theme_name = self::DEFAULT_THEME_NAME
          return if exist?(theme_name: theme_name)

          FileUtils.mkdir_p themes_folder
          themes_path = themes_path(theme_name: theme_name)
          File.write(themes_path, Psych.dump(self::DEFAULT_THEME))
        end

        def delete!(theme_name:)
          raise file_does_not_exist_message(theme_name) unless exist?(theme_name: theme_name)

          delete(theme_name: theme_name)
        end

        def delete(theme_name:)
          return false unless exist?(theme_name: theme_name)

          themes_path = themes_path(theme_name: theme_name)
          File.delete(themes_path)

          reset_default_configuration_color_theme_if!(deleted_theme_name: theme_name)

          true
        end

        def exist?(theme_name:)
          themes_path = themes_path(theme_name: theme_name)
          File.exist?(themes_path)
        end

        def find(theme_name:)
          raise "Color theme does not exist: \"#{theme_name}\"" unless exist?(theme_name: theme_name)

          themes_path = themes_path(theme_name: theme_name)
          color_theme_hash = Psych.safe_load(File.read(themes_path), [Symbol])
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

          FileUtils.mkdir_p themes_folder
          themes_path = themes_path(theme_name: color_theme.theme_name)
          File.write(themes_path, Psych.dump(color_theme.to_h))

          true
        end

        def save!(color_theme:)
          color_theme.validate!

          save(color_theme: color_theme)

          color_theme
        end

        private

        # If the color theme is deleted (deleted_theme_name) and the current
        # theme_name in the configuration is the same as the deleted theme,
        # we need to reset the configuration theme to the default theme.
        def reset_default_configuration_color_theme_if!(deleted_theme_name:)
          config = configuration
          return if config.theme_name == self::DEFAULT_THEME_NAME
          return unless config.theme_name == deleted_theme_name
          return unless config.exist?

          config.theme_name = self::DEFAULT_THEME_NAME
          config.save!
        end

        def configuration
          Models::Configuration.instance
        end

        def file_does_not_exist_message(theme_name)
          "Theme file does not exist for theme \"#{theme_name}\": " \
            "\"#{themes_path(theme_name: theme_name)}\""
        end
      end
    end
  end
end
