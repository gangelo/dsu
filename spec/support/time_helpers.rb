# frozen_string_literal: true

# This module provides methods to help with Time
# objects
module TimeHelpers
  def today_yyyymmdd_string
    to_yyyymmdd_string(Time.now.in_time_zone)
  end

  def to_yyyymmdd_string(time)
    raise ArgumentError, "time is not a Time object: \"#{time}\"" unless time.is_a?(Time)

    time.in_time_zone.strftime('%Y-%m-%d %Z')
  end

  def to_yyyymmdd_string_array(time_array)
    raise ArgumentError, "time_array is not an Array: \"#{time_array}\"" unless time_array.is_a?(Array)

    time_array.map { |time| to_yyyymmdd_string(time) }
  end
end
