# frozen_string_literal: true

require 'time'
require 'active_support/core_ext/numeric/time'

module Dsu
  module Support
    # This module provides functions for formatting Time objects
    # to display in the console.
    module TimeFormatable
      module_function

      def formatted_time(time:)
        time = time.localtime if time.utc?

        today_yesterday_or_tomorrow = if time.today?
          'Today'
        elsif time.yesterday?
          'Yesterday'
        elsif time.tomorrow?
          'Tomorrow'
        end

        time_zone = timezone_for(time: time)

        return time.strftime("%A, %Y-%m-%d #{time_zone}") unless today_yesterday_or_tomorrow

        time.strftime("%A, (#{today_yesterday_or_tomorrow}) %Y-%m-%d #{time_zone}")
      end

      def timezone_for(time:)
        time.zone
      end
    end
  end
end
