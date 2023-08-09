# frozen_string_literal: true

require 'delegate'
require_relative '../models/color_theme'
require_relative '../support/color_themable'

module Dsu
  module Presenters
    class BasePresenter < SimpleDelegator
      include Support::ColorThemable

      attr_reader :color_theme

      def initialize(object, options: {})
        super(object)

        @options = options || {}
        theme_name = options.fetch(:theme_name, Models::Configuration.instance.theme_name)
        @color_theme = Models::ColorTheme.find(theme_name: theme_name)
      end

      private

      attr_reader :options

      def formatted_index(index:)
        apply_color_theme("#{format('%02s', index + 1)}. ",
          color_theme_color: color_theme.index)
      end
    end
  end
end
