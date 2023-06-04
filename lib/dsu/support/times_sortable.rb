# frozen_string_literal: true

module Dsu
  module Support
    module TimesSortable
      module_function

      def times_sort(times:, entries_display_order: nil)
        raise ArgumentError, "times is the wrong object type: \"#{times.class}\"" unless times.is_a?(Array)
        raise ArgumentError, 'times is empty' if times.empty?
        unless entries_display_order.nil? || entries_display_order.is_a?(String)
          raise ArgumentError, "entries_display_order is the wrong object type: \"#{entries_display_order.class}\""
        end

        entries_display_order ||= 'asc'
        unless %w[asc desc].include? entries_display_order
          raise ArgumentError, "entries_display_order is invalid: \"#{entries_display_order}\""
        end

        return times if times.one?

        if entries_display_order == 'asc'
          times.sort # sort ascending
        elsif entries_display_order == 'desc'
          times.sort.reverse # sort descending
        end
      end

      def times_for(times:)
        start_date = times.max
        return times unless start_date.monday? || start_date.on_weekend?

        # If the start_date is a weekend or a Monday, then we need to include
        # start_date along with all the dates up to and including the previous
        # Monday.
        (0..3).filter_map do |num|
          time = start_date - num.days
          next unless time == start_date || time.on_weekend? || time.friday?

          time
        end
      end
    end
  end
end
