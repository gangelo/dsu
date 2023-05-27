# frozen_string_literal: true

require 'psych'

require_relative 'colorable'
require_relative 'configurable'
require_relative 'folder_locations'
require_relative 'say'

module Dsu
  module Support
    module ColorThemeLocatable
      include Colorable
      include Configurable
      include FolderLocations
      include Say

      def theme_file?(theme_name:)
        File.exist?(theme_file(theme_name: theme_name))
      end

      def theme_file(theme_name:)
        File.join(themes_folder, theme_name)
      end

      def themes_folder
        configuration[:themes_folder]
      end

      def create_theme_file!(theme_name:, theme_hash:)
        return unless create_theme_file(theme_file: theme_file(theme_name: theme_name), theme_hash: theme_hash)

        print_theme_file(theme_name: theme_name)
      end

      def delete_theme_file!(theme_name:)
        delete_theme_file(theme_file: theme_file(theme_name: theme_name))
      end

      # TODO: Move this to a view (e.g. views/theme/show.rb)
      def print_theme_file(theme_name:)
        theme_file = theme_file(theme_name: theme_name)
        if theme_file?(theme_name: theme_name)
          say "Theme file (#{theme_file}) contents:", SUCCESS
          data = File.read(theme_file)
          hash = Psych.safe_load(data, [Symbol])
          say hash.to_yaml.gsub("\n-", "\n\n-"), SUCCESS
        else
          say "Theme file (#{theme_file}) does not exist.", WARNING
          say ''
          say 'The default theme is being used:'
          default_theme.each_with_index do |theme_entry, index|
            say "#{index + 1}. #{theme_entry[0]}: '#{theme_entry[1]}'"
          end
        end
      end

      private

      def default_theme
        Models::ColorTheme::DEFAULT_THEME
      end

      def create_theme_file(theme_file:, theme_hash:)
        folder = File.dirname(theme_file)
        unless Dir.exist?(folder)
          say "Destination folder for theme file (#{folder}) does not exist", ERROR
          return false
        end

        if File.exist?(theme_file)
          say "Theme file (#{theme_file}) already exists", WARNING
          return false
        end

        File.write(theme_file, theme_hash.to_yaml)
        say "Theme file (#{theme_file}) created.", SUCCESS

        true
      end

      def delete_theme_file(theme_file:)
        unless File.exist?(theme_file)
          say "Theme file (#{theme_file}) does not exist", WARNING
          return false
        end

        File.delete theme_file
        say "Theme file (#{theme_file}) deleted", SUCCESS

        true
      end
    end
  end
end
