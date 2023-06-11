# frozen_string_literal: true

require 'delegate'
require_relative '../models/color_theme'
require_relative '../support/color_themable'

module Dsu
  module Presenters
    class BasePresenter < SimpleDelegator
      include Support::ColorThemable

      private

      def formatted_index(index:)
        apply_color_theme("#{format('%02s', index + 1)}. ",
          color_theme_color: color_theme.indexes)
      end

      def color_theme
        @color_theme ||= Models::ColorTheme.current_or_default
      end
    end
  end
end
