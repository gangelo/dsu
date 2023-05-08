# frozen_string_literal: true

module Dsu
  module Support
    module TimesSortable
      module_function

      def times_sort(times:, entries_display_order: nil)
        entries_display_order ||= 'asc'
        unless %w[asc desc].include? entries_display_order
          raise "Invalid entries_display_order: #{entries_display_order}"
        end

        if entries_display_order == 'asc'
          times.sort # sort ascending
        elsif entries_display_order == 'desc'
          times.sort.reverse # sort descending
        end
      end

      def times_for(times:)
        start_date = times.max
        return times unless start_date.monday? || start_date.on_weekend?

        # (0..3).map { |num| start_date - num.days }
        # (start_date..-start_date.friday?).map { |time| time }
        # (0..3).map { |num| start_date - num.days if start_date.on_weekend? || start_date.monday? }
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
