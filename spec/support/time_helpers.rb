# frozen_string_literal: true

# This module provides methods to help with Time
# objects
module TimeHelpers
  def freeze_time_at(time_string:)
    allow(Time).to receive(:now).and_return(Time.parse(time_string))
  end

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

  def times_for_week_of(time)
    range = (time.beginning_of_week.to_i..time.end_of_week.to_i)
    range.step(24.hours).map { |time_step| Time.at(time_step) }
  end

  def times_for_month_of(time)
    range = (time.beginning_of_month.to_i..time.end_of_month.to_i)
    range.step(24.hours).map { |time_step| Time.at(time_step) }
  end

  def times_for_year_of(time)
    range = (time.beginning_of_year.to_i..time.end_of_year.to_i)
    range.step(24.hours).map { |time_step| Time.at(time_step) }
  end

  def times_one_for_every_month_of(time)
    time = time.end_of_year.beginning_of_month
    12.times.each_with_object([]) do |month_index, times|
      times << time.months_ago(month_index).beginning_of_month
    end.sort
  end

  def time_strings_for(times)
    times.map { |time| time.to_date.to_s }
  end
end
