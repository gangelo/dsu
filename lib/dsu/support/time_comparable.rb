# frozen_string_literal: true

module Dsu
  module Support
    module TimeComparable
      TIME_COMPARABLE_FORMAT_SPECIFIER = '%Y%m%d'

      def time_equal?(other_time:)
        time_equal_compare_string_for(time: time) == time_equal_compare_string_for(time: other_time)
      end

      def time_equal_compare_string_for(time:)
        time = time.in_time_zone

        time.strftime(TIME_COMPARABLE_FORMAT_SPECIFIER)
      end
    end
  end
end
