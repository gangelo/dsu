# frozen_string_literal: true

require_relative '../models/color_theme'
require_relative '../models/configuration'
require_relative '../support/color_themable'

module Dsu
  module Views
    class Import
      include Support::ColorThemable

      def initialize(presenter:)
        @presenter = presenter
      end

      def render
        return presenter.display_import_file_not_exist_message unless presenter.import_file_path_exist?
        return presenter.display_nothing_to_import_message if presenter.nothing_to_import?

        response = presenter.display_import_prompt
        presenter.render response: response
      end

      private

      attr_reader :presenter
    end
  end
end
