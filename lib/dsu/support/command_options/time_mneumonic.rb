# frozen_string_literal: true

require_relative 'time_mneumonics'

module Dsu
  module Support
    module CommandOptions
      # The purpose of this module is to take a command option that is a string and return a Time object.
      # The command option is expected to be a time mneumoic.
      module TimeMneumonic
        include TimeMneumonics

        # command_option: is expected to me a time mneumonic. If relative_time is NOT nil, all
        # time mneumonics are relative to relative_time. Otherwise, they are relative to Time.now.
        # relative_time: is a Time object that is required IF command_option is expected to be
        # a relative time mneumonic. Otherwise, it is optional.
        def time_from_mneumonic!(command_option:, relative_time: nil)
          validate_argument!(command_option: command_option, command_option_name: :command_option)
          unless relative_time.nil?
            validate_argument!(command_option: relative_time, command_option_name: :relative_time)
          end

          time_for_mneumonic(mneumonic: command_option, relative_time: relative_time)
        end

        private

        # Returns a Time object from a mneumonic.
        def time_for_mneumonic(mneumonic:, relative_time: nil)
          # If relative_time is a relative time mneumonic, then we need to first
          # convert mneumonic to a Time object first, so that we can calculate
          # `relative_time.to_i.days.from_now(time)` to get the correct Time we
          # need.
          if relative_time_mneumonic?(relative_time)
            time = time_for_mneumonic(mneumonic: mneumonic)
            return relative_time_for(days_from_now: relative_time, time: time)
          end

          if mneumonic?(mneumonic) && mneumonic?(relative_time)
            time = time_for_mneumonic(mneumonic: mneumonic)

            # Simply return the time if relative_time is 'today'
            # because 'today' relative to any time will always
            # point to itself.
            return time if today_mneumonic?(relative_time)

            return time.public_send(relative_time)
          end

          time = ::Time.now
          if today_mneumonic?(mneumonic)
            time
          elsif tomorrow_mneumonic?(mneumonic)
            time.tomorrow
          elsif yesterday_mneumonic?(mneumonic)
            time.yesterday
          elsif relative_time_mneumonic?(mneumonic)
            relative_time_for(days_from_now: mneumonic, time: time)
          end
        end

        def relative_time_for(days_from_now:, time:)
          days_from_now.to_i.days.from_now(time)
        end

        # This method returns true if mneumonic is a valid mneumonic OR
        # a relative time mneumonic.
        def valid_mneumonic?(mneumonic)
          mneumonic?(mneumonic) || relative_time_mneumonic?(mneumonic)
        end

        # This method returns true if mneumonic is a valid time mneumonic.
        # This method will return false if mneumonic is an invalid mneumonic
        # OR if mneumonic is a relative time mneumonic.
        def mneumonic?(mneumonic)
          today_mneumonic?(mneumonic) ||
            tomorrow_mneumonic?(mneumonic) ||
            yesterday_mneumonic?(mneumonic)
        end

        # This method returns true if mneumonic is a valid relative
        # time mneumonic.
        def relative_time_mneumonic?(mneumonic)
          return false unless mneumonic.is_a?(String)

          mneumonic.match?(RELATIVE_REGEX)
        end

        def today_mneumonic?(mneumonic)
          TODAY.include?(mneumonic)
        end

        def tomorrow_mneumonic?(mneumonic)
          TOMORROW.include?(mneumonic)
        end

        def yesterday_mneumonic?(mneumonic)
          YESERDAY.include?(mneumonic)
        end

        def validate_argument!(command_option:, command_option_name:)
          raise ArgumentError, "#{command_option_name} cannot be nil." if command_option.nil?
          raise ArgumentError, "#{command_option_name} cannot be blank." if command_option.blank?
          unless command_option.is_a?(String)
            raise ArgumentError, "#{command_option_name} must be a String: \"#{command_option}\""
          end
          unless valid_mneumonic?(command_option)
            raise ArgumentError, "#{command_option_name} is an invalid mneumonic: \"#{command_option}\"."
          end
        end
      end
    end
  end
end
