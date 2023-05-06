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

        today_yesterday_or_tomorrow = if today?(time: time)
          'Today'
        elsif yesterday?(time: time)
          'Yesterday'
        elsif tomorrow?(time: time)
          'Tomorrow'
        end

        return time.strftime('%A, %Y-%m-%d') unless today_yesterday_or_tomorrow

        time.strftime("%A, (#{today_yesterday_or_tomorrow}) %Y-%m-%d")
      end

      def today?(time:)
        time.strftime('%Y%m%d') == Time.now.strftime('%Y%m%d')
      end

      def yesterday?(time:)
        time.strftime('%Y%m%d') == 1.day.ago(Time.now).strftime('%Y%m%d')
      end

      def tomorrow?(time:)
        time.strftime('%Y%m%d') == 1.day.from_now(Time.now).strftime('%Y%m%d')
      end
    end
  end
end
