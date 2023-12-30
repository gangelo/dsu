# frozen_string_literal: true

require_relative '../models/color_theme'
require_relative '../models/configuration'
require_relative '../support/color_themable'

module Dsu
  module Views
    class Export
      include Support::ColorThemable

      def initialize(presenter:)
        @presenter = presenter
      end

      def render
        return presenter.display_nothing_to_export_message if presenter.nothing_to_export?

        response = presenter.display_export_prompt
        presenter.render response: response
      end

      private

      attr_reader :presenter
    end
  end
end
