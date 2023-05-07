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
        return times unless start_date.monday?

        (0..3).map { |num| start_date - num.days }
      end
    end
  end
end
