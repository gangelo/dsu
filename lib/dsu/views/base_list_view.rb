# frozen_string_literal: true

require_relative '../env'
require_relative '../models/color_theme'
require_relative '../support/color_themable'

module Dsu
  module Views
    class BaseListView
      include Support::ColorThemable

      attr_reader :presenter

      def initialize(presenter:, options: {})
        @presenter = presenter
        @options = options&.dup || {}
        @color_theme = Models::ColorTheme.find(theme_name: theme_name)
      end

      def render
        yield
      rescue StandardError => e
        puts apply_theme(e.message, theme_color: color_theme.error)
        puts apply_theme(e.backtrace_locations.join("\n"), theme_color: color_theme.error) if Dsu.env.local?
      end

      private

      attr_reader :color_theme, :options

      def theme_name
        @theme_name ||= options.fetch(:theme_name, Models::Configuration.new.theme_name)
      end

      def formatted_index(index:)
        apply_theme("#{format('%02s', index + 1)}. ",
          theme_color: color_theme.index)
      end
    end
  end
end
