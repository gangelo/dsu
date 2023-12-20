# frozen_string_literal: true

require_relative 'time_mnemonics'

module Dsu
  module Support
    module CommandOptions
      # The purpose of this module is to take a command option that is a string and return a Time object.
      # The command option is expected to be a time mneumoic.
      module TimeMnemonic
        include TimeMnemonics

        module_function

        def time_from_mnemonic(command_option:, relative_time: nil)
          time_from_mnemonic!(command_option: command_option, relative_time: relative_time)
        rescue ArgumentError
          nil
        end

        # command_option: is expected to me a time mnemonic. If relative_time is NOT nil, all
        # time mnemonics are relative to relative_time. Otherwise, they are relative to Time.now.
        # relative_time: is a Time object that is required IF command_option is expected to be
        # a relative time mnemonic. Otherwise, it is optional.
        def time_from_mnemonic!(command_option:, relative_time: nil)
          validate_argument!(command_option: command_option, command_option_name: :command_option)
          unless relative_time.nil? || relative_time.is_a?(::Time)
            raise ArgumentError, "relative_time is not a Time object: \"#{relative_time}\""
          end

          relative_time ||= ::Time.now

          time_for_mnemonic(mnemonic: command_option, relative_time: relative_time)
        end

        # This method returns true if mnemonic is a valid mnemonic OR
        # a relative time mnemonic.
        def time_mnemonic?(mnemonic)
          mnemonic?(mnemonic) || relative_time_mnemonic?(mnemonic)
        end

        # This method returns true if mnemonic is a valid relative
        # time mnemonic.
        def relative_time_mnemonic?(mnemonic)
          return false unless mnemonic.is_a?(String)

          mnemonic.match?(RELATIVE_REGEX)
        end

        # Add private_class_methods here.

        # Returns a Time object from a mnemonic.
        def time_for_mnemonic(mnemonic:, relative_time:)
          time = relative_time
          if today_mnemonic?(mnemonic)
            time
          elsif tomorrow_mnemonic?(mnemonic)
            time.tomorrow
          elsif yesterday_mnemonic?(mnemonic)
            time.yesterday
          elsif relative_time_mnemonic?(mnemonic)
            relative_time_for(days_from_now: mnemonic, time: time)
          end
        end

        def relative_time_for(days_from_now:, time:)
          days_from_now.to_i.days.from_now(time)
        end

        # This method returns true if mnemonic is a valid time mnemonic.
        # This method will return false if mnemonic is an invalid mnemonic
        # OR if mnemonic is a relative time mnemonic.
        def mnemonic?(mnemonic)
          today_mnemonic?(mnemonic) ||
            tomorrow_mnemonic?(mnemonic) ||
            yesterday_mnemonic?(mnemonic)
        end

        def today_mnemonic?(mnemonic)
          TODAY.include?(mnemonic)
        end

        def tomorrow_mnemonic?(mnemonic)
          TOMORROW.include?(mnemonic)
        end

        def yesterday_mnemonic?(mnemonic)
          YESTERDAY.include?(mnemonic)
        end

        def validate_argument!(command_option:, command_option_name:)
          raise ArgumentError, "#{command_option_name} cannot be nil." if command_option.nil?
          raise ArgumentError, "#{command_option_name} cannot be blank." if command_option.blank?
          unless command_option.is_a?(String)
            raise ArgumentError, "#{command_option_name} must be a String: \"#{command_option}\""
          end
          unless time_mnemonic?(command_option)
            raise ArgumentError, "#{command_option_name} is an invalid mnemonic: \"#{command_option}\"."
          end
        end

        private_class_method :time_for_mnemonic, :relative_time_for,
          :mnemonic?, :today_mnemonic?, :tomorrow_mnemonic?,
          :yesterday_mnemonic?, :validate_argument!
      end
    end
  end
end
