# frozen_string_literal: true

module Dsu
  module Support
    module TimesSortable
      def sorted_dsu_times_for(times:)
        configuration = Models::Configuration.new unless defined?(configuration) && configuration
        entries_display_order = configuration.entries_display_order
        times_sort(times: times_for(times: times), entries_display_order: entries_display_order)
      end

      def times_sort(times:, entries_display_order: nil)
        times = times.dup
        entries_display_order ||= :asc

        validate_times_argument!(times: times)
        validate_entries_display_order_argument!(entries_display_order: entries_display_order)

        return times if times.one?

        # NOTE: The times array needs to be sorted unconditionally because if
        # the sort is ascending, then the times array needs to be returned
        # in ascending order. If the sort is descending, then in order to
        # properly reverse the times array, it needs to first be sorted in
        # ascending order before being reversed.
        return times.sort if entries_display_order == :asc

        times.sort_by { |time| -time.to_i }
      end

      def times_for(times:)
        times = times.dup
        validate_times_argument!(times: times)

        start_date = times.max
        return times unless start_date.monday? || start_date.on_weekend?

        # If the start date is a weekend or a Monday then we need to look back
        # to include the preceeding Friday upto and including the start date.
        (0..3).filter_map do |num|
          time = start_date - num.days
          next unless time == start_date || time.on_weekend? || time.friday?

          time
        end
      end

      private

      def validate_times_argument!(times:)
        raise ArgumentError, "times is the wrong object type: \"#{times.class}\"" unless times.is_a?(Array)
        raise ArgumentError, 'times is empty' if times.empty?
      end

      def validate_entries_display_order_argument!(entries_display_order:)
        unless entries_display_order.nil? || entries_display_order.is_a?(Symbol)
          raise ArgumentError, "entries_display_order is the wrong object type: \"#{entries_display_order.class}\""
        end

        unless %i[asc desc].include?(entries_display_order)
          raise ArgumentError, "entries_display_order is invalid: \":#{entries_display_order}\""
        end
      end

      # NOTE: This, as opposed to using module_function, so that we can
      # invoke .validate_times_sort_arguments! from the .times_sort
      # method with module as the receiver AND when included as a mixin.
      extend self
    end
  end
end
