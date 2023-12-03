# frozen_string_literal: true

module Dsu
  module Support
    module CommandOptions
      # TODO: Make this into an ActiveModel class that uses validations.
      #
      # The purpose of this module is to take a command option that is a string and return a Time object.
      # The command option is expected to be a date in the format of [M]M/[D]D[/YYYY]. MM and DD with
      # leading zeroes is optional (i.e. only M and D are required), YYYY is optionl and will be replaced
      # with the current year if not provided.
      module Time
        DATE_CAPTURE_REGEX = %r{\A(?<month>0?[1-9]|1[0-2])/(?<day>0?[1-9]|1\d|2\d|3[01])(?:/(?<year>\d{4}))?\z}

        module_function

        def time_from_date_string!(command_option:)
          raise ArgumentError, 'command_option is nil.' if command_option.nil?
          raise ArgumentError, 'command_option is blank.' if command_option.blank?

          unless command_option.is_a?(String)
            raise ArgumentError, "command_option is not a String: \"#{command_option}\"."
          end

          time_parts = time_parts_for(time_string: command_option)
          return unless time_parts?(time_parts: time_parts)

          valid_time!(time_parts: time_parts)

          # This will rescue errors resulting from calling Date.strptime with an invalid date string,
          # and return a more meaningful error message.
        rescue DateTime::Error
          raise ArgumentError, "command_option is not a valid date: \"#{command_option}\"."
        end

        def time_from_date_string(command_option:)
          time_from_date_string!(command_option: command_option)
        rescue ArgumentError
          nil
        end

        # private_class_methods go here.

        # This method returns the time parts for the given time string in a hash
        # (i.e. month, day, year) IF the time string matches the DATE_CAPTURE_REGEX
        # regex. Otherwise, it returns an empty hash.
        def time_parts_for(time_string:)
          match_data = DATE_CAPTURE_REGEX.match(time_string)
          return {} if match_data.nil?

          {
            month: match_data[:month],
            day: match_data[:day],
            year: match_data[:year]
          }
        end

        # This method returns true if the date passes the DATE_CAPTURE_REGEX regex match
        # in #date_parts_for and returns a non-nil hash. Otherwise, it returns false.
        # A non-nil hash returned from #date_parts_for doesn necessarily mean the date
        # parts will equate to a valid date when parsed, it just means the date string
        # matched the regex. Calling #valid_date! will raise an ArgumentError if the
        # date parts do not equate to a valid date.
        def time_parts?(time_parts:)
          !time_parts.empty?
        end

        def valid_time!(time_parts:)
          time_string = time_string_for(time_parts: time_parts)
          # TODO: I18n.
          Date.strptime(time_string, '%Y/%m/%d').to_time
        end

        def time_string_for(time_parts:)
          # Replace the year with the current year if it is nil.
          time_parts[:year] = ::Time.now.year if time_parts[:year].nil?
          "#{time_parts[:year]}/#{time_parts[:month]}/#{time_parts[:day]}"
        end

        private_class_method :time_parts_for, :time_parts?, :valid_time!, :time_string_for
      end
    end
  end
end
