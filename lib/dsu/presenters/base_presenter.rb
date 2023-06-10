# frozen_string_literal: true

require 'delegate'
require_relative '../models/color_theme'
require_relative '../support/color_themable'

module Dsu
  module Presenters
    class BasePresenter < SimpleDelegator
      include Support::ColorThemable

      private

      def color_theme
        @color_theme ||= Models::ColorTheme.current_or_default
      end
    end
  end
end
