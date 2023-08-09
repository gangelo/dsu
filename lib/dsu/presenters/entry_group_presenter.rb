# frozen_string_literal: true

require_relative '../support/time_formatable'
require_relative 'base_presenter'

module Dsu
  module Presenters
    class EntryGroupPresenter < BasePresenter
      attr_reader :entry_group

      def initialize(entry_group, options: {})
        super

        @entry_group = entry_group
      end

      def formatted_time
        colors = color_theme.date
        apply_color_theme(Support::TimeFormatable.formatted_time(time: time), color_theme_color: colors)
      end

      def formatted_errors
        return if valid?

        colors = color_theme.error
        apply_color_theme(errors.full_messages.join(', '), color_theme_color: colors)
      end

      def no_entries_available
        colors = color_theme.info
        apply_color_theme('(no entries available for this day)', color_theme_color: colors)
      end
    end
  end
end
