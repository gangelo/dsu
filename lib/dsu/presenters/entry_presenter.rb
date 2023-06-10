# frozen_string_literal: true

require_relative 'base_presenter'

module Dsu
  module Presenters
    class EntryPresenter < BasePresenter
      attr_reader :entry

      def initialize(entry)
        super

        @entry = entry
      end

      def formatted_description
        apply_color_theme(description, color_theme_color: color_theme.entry_description)
      end

      def formatted_description_with_index(index:)
        "#{formatted_index(index: index)} #{formatted_description}"
      end

      private

      def formatted_index(index:)
        apply_color_theme("#{format('%03s', index + 1)}. ",
          color_theme_color: color_theme.entry_index)
      end
    end
  end
end
