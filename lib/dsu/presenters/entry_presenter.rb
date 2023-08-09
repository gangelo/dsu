# frozen_string_literal: true

require_relative 'base_presenter'

module Dsu
  module Presenters
    class EntryPresenter < BasePresenter
      attr_reader :entry

      def initialize(entry, options: {})
        super

        @entry = entry
      end

      def formatted_description
        apply_color_theme(description, color_theme_color: color_theme.body)
      end

      def formatted_description_with_index(index:)
        "#{formatted_index(index: index)} #{formatted_description}"
      end
    end
  end
end
