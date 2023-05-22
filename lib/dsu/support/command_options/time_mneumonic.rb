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
          validate_argument!(command_option: relative_time, command_option_name: :relative_time)

          time_for_mneumonic(mneumonic: command_option, relative_time: relative_time)
        end

        private

        # Returns a Time object from a mneumonic.
        def time_for_mneumonic(mneumonic:, relative_time:)
          time = relative_time || ::Time.now

          if today_mneumonic?(mneumonic)
            time
          elsif tomorrow_mneumonic?(mneumonic)
            time.tomorrow
          elsif yesterday_mneumonic?(mneumonic)
            time.yesterday
          elsif relative_time_mneumonic?(mneumonic)
            mneumonic.to_i.days.from_now(time)
          end
        end

        def mneumonic?(mneumonic)
          today_mneumonic?(mneumonic) ||
            tomorrow_mneumonic?(mneumonic) ||
            yesterday_mneumonic?(mneumonic) ||
            relative_time_mneumonic?(mneumonic)
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

        def relative_time_mneumonic?(mneumonic)
          return false unless mneumonic.is_a?(String)

          mneumonic.match?(RELATIVE_REGEX)
        end

        def validate_argument!(command_option:, command_option_name:)
          raise ArgumentError, "#{command_option_name} cannot be nil." if command_option.nil?
          raise ArgumentError, "#{command_option_name} cannot be blank." if command_option.blank?
          unless command_option.is_a?(String)
            raise ArgumentError, "#{command_option_name} must be a String: \"#{command_option}\""
          end
          unless mneumonic?(command_option)
            raise ArgumentError, "#{command_option_name} is an invalid mneumonic: \"#{command_option}\"."
          end
        end
      end
    end
  end
end
