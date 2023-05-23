# frozen_string_literal: true

require_relative 'time_mneumonics'

module Dsu
  module Support
    module CommandOptions
      # The purpose of this module is to take a command option that is a string and return a Time object.
      # The command option is expected to be a time mneumoic.
      module TimeMneumonic
        include TimeMneumonics

        def time_from_mneumonic(command_option:, relative_time: nil)
          time_from_mneumonic!(command_option: command_option, relative_time: relative_time)
        rescue ArgumentError
          nil
        end

        # command_option: is expected to me a time mneumonic. If relative_time is NOT nil, all
        # time mneumonics are relative to relative_time. Otherwise, they are relative to Time.now.
        # relative_time: is a Time object that is required IF command_option is expected to be
        # a relative time mneumonic. Otherwise, it is optional.
        def time_from_mneumonic!(command_option:, relative_time: nil)
          validate_argument!(command_option: command_option, command_option_name: :command_option)
          unless relative_time.nil? || relative_time.is_a?(::Time)
            raise ArgumentError, "relative_time is not a Time object: \"#{relative_time}\""
          end

          relative_time ||= ::Time.now

          time_for_mneumonic(mneumonic: command_option, relative_time: relative_time)
        end

        # This method returns true if mneumonic is a valid mneumonic OR
        # a relative time mneumonic.
        def time_mneumonic?(mneumonic)
          mneumonic?(mneumonic) || relative_time_mneumonic?(mneumonic)
        end

        # This method returns true if mneumonic is a valid relative
        # time mneumonic.
        def relative_time_mneumonic?(mneumonic)
          return false unless mneumonic.is_a?(String)

          mneumonic.match?(RELATIVE_REGEX)
        end

        private

        # Returns a Time object from a mneumonic.
        def time_for_mneumonic(mneumonic:, relative_time:)
          time = relative_time
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

        # This method returns true if mneumonic is a valid time mneumonic.
        # This method will return false if mneumonic is an invalid mneumonic
        # OR if mneumonic is a relative time mneumonic.
        def mneumonic?(mneumonic)
          today_mneumonic?(mneumonic) ||
            tomorrow_mneumonic?(mneumonic) ||
            yesterday_mneumonic?(mneumonic)
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
          unless time_mneumonic?(command_option)
            raise ArgumentError, "#{command_option_name} is an invalid mneumonic: \"#{command_option}\"."
          end
        end
      end
    end
  end
end
