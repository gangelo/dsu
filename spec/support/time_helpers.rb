# frozen_string_literal: true

# This module provides methods to help with Time
# objects
module TimeHelpers
  def to_yyyymmdd_string(time)
    raise ArgumentError, "time is not a Time object: \"#{time}\"" unless time.is_a?(Time)

    time.strftime('%Y-%m-%d')
  end
end
