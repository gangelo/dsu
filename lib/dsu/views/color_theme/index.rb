# frozen_string_literal: true

require_relative '../../models/configuration'
require_relative '../../models/color_theme'

module Dsu
  module Views
    module ColorTheme
      class Index
        include Support::ColorThemable

        def render
          render!
        end

        private

        def render!
          presenter = color_theme.presenter
          puts presenter.header
          puts
          render_theme_details
          puts
          puts presenter.footer
        end

        def render_theme_details
          themes_folder = Models::Configuration.new.themes_folder
          theme_file_names = Dir.glob("#{themes_folder}/*").map { |theme_path| File.basename(theme_path, '.*') }
          theme_file_names << default_theme_name unless theme_file_names.include?(default_theme_name)
          theme_file_names.sort.each_with_index do |theme_file, index|
            color_theme = if theme_file == default_theme_name
              default_theme
            else
              Models::ColorTheme.find(theme_name: theme_file)
            end
            presenter = color_theme.presenter
            puts presenter.detail_with_index(index: index)
          end
        end

        # When getting the default theme, if it exists on disk, use that; otherwise,
        # use the in-memory default theme.
        def default_theme
          if Models::ColorTheme.exist?(theme_name: default_theme_name)
            Models::ColorTheme.find(theme_name: default_theme_name)
          else
            Models::ColorTheme.default
          end
        end

        def default_theme_name
          Dsu::Models::ColorTheme::DEFAULT_THEME_NAME
        end

        def color_theme
          @color_theme ||= Models::ColorTheme.current_or_default
        end
      end
    end
  end
end
