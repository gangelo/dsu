# frozen_string_literal: true

module Dsu
  module Support
    # This module provides functions for formatting Time objects
    # to display in the console.
    module TimeFormatable
      module_function

      def formatted_time(time:)
        time = time.localtime

        today_yesterday_or_tomorrow = if today?(time: time)
          'Today'
        elsif yesterday?(time: time)
          'Yesterday'
        elsif tomorrow?(time: time)
          'Tomorrow'
        end

        return time.strftime('%A, %Y-%m-%d') unless today_yesterday_or_tomorrow

        "#{today_yesterday_or_tomorrow} #{time.strftime('(%A, %Y-%m-%d)')}"
      end

      def today?(time:)
        time.utc.strftime('%Y%m%d') == Time.now.utc.strftime('%Y%m%d')
      end

      def yesterday?(time:)
        time.utc.strftime('%Y%m%d') == 1.day.ago(Time.now).utc.strftime('%Y%m%d')
      end

      def tomorrow?(time:)
        time.utc.strftime('%Y%m%d') == 1.from_now(Time.now).utc.strftime('%Y%m%d')
      end
    end
  end
end
