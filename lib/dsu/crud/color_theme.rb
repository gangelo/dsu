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
        self.class.save(theme_name: theme_name, theme_hash: to_h)
      end

      def save!
        self.class.save!(theme_name: theme_name, theme_hash: to_h)
      end

      module ClassMethods
        def delete!(theme_name:)
          unless exist?(theme_name: theme_name)
            raise "Theme file does not exist for theme \"#{theme_name}\": \"#{theme_path}\""
          end

          delete(theme_name: theme_name)
        end

        def delete(theme_name:)
          return unless exist?(theme_name: theme_name)

          theme_path = theme_path(theme_name: theme_name)
          File.delete(theme_path)
        end

        def exist?(theme_name:)
          theme_path = theme_path(theme_name: theme_name)
          File.exist?(theme_path)
        end

        def find(theme_name:)
          theme_path = theme_path(theme_name: theme_name)
          Psych.safe_load(File.read(theme_path), [Symbol])
        end

        def save(theme_name:, theme_hash:)
          new(theme_name: theme_name, theme_hash: theme_hash).validate!

          theme_path = theme_path(theme_name: theme_name)
          File.write(theme_path, Psych.dump(theme_hash))
        end

        def save!(theme_name:, theme_hash:)
          save(theme_name: theme_name, theme_hash: theme_hash)
        end

        def theme_path(theme_name:)
          File.join(themes_folder, theme_name)
        end

        def themes_folder
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
