# frozen_string_literal: true

require 'delegate'
require_relative '../models/color_theme'
require_relative '../support/color_themable'

module Dsu
  module Presenters
    class BasePresenterEx
      include Support::ColorThemable

      def initialize(options: {})
        @options = options || {}
        @color_theme = Models::ColorTheme.find(theme_name: theme_name)
      end

      private

      attr_reader :color_theme, :options

      def theme_name
        @theme_name ||= options.fetch(:theme_name, Models::Configuration.new.theme_name)
      end
    end
  end
end
