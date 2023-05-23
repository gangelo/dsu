# frozen_string_literal: true

require_relative 'time'
require_relative 'time_mneumonic'
require_relative 'time_mneumonics'

module Dsu
  module Support
    module CommandOptions
      module DsuTimes
        include Time
        include TimeMneumonic
        include TimeMneumonics

        # Returns an array of Time objects. The first element is the from time. The second element is the to time.
        # Both arguments are expected to be command options that are time strings, time or relative time mneumonics.
        def dsu_times_from!(from_command_option:, to_command_option:)
          times = begin
            from_time = time_from_mneumonic(command_option: from_command_option) if time_mneumonic?(from_command_option)
            from_time ||= time_from_date_string(command_option: from_command_option)

            to_time = time_from_mneumonic(command_option: to_command_option) if time_mneumonic?(to_command_option)
            to_time ||= time_from_date_string(command_option: to_command_option)

            [from_time, to_time].sort
          end

          (times.min.to_date..times.max.to_date).map(&:to_time)
        end
      end
    end
  end
end
