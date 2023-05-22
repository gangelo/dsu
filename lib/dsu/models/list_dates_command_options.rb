# frozen_string_literal: true

require 'active_model'

# require_relative '../support/date_mneumonics'

module Dsu
  module Models
    class ListDatesCommandOptions
      # include ActiveModel::Model
      # include Support::DateMneumonics

      # DATE_CAPTURE_REGEX = %r{\A(?<month>0?[1-9]|1[0-2])/(?<day>0?[1-9]|1\d|2\d|3[01])(?:/(?<year>\d{4}))?\z}

      # validate :validate_from_option
      # validate :validate_to_option
      # validate :validate_date_range

      # attr_reader :from, :to, :from_to_dates

      # def initialize(options:)
      #   raise ArgumentError, 'options is the wrong object type' unless options.is_a?(Hash)

      #   @options = options

      #   validate!

      #   self.from = options[:from]
      #   self.to = options[:to]
      # end

      # private

      # attr_reader :options

      # def from=(from)
      #   date_parts = date_parts_for(date_string: from)
      #   return unless date?(date_parts: date_parts)

      #   begin
      #     @from = valid_date!(date_parts: date_parts)
      #   rescue ArgumentError
      #     @from = nil
      #   end
      # end

      # def to=(to)
      #   date_parts = date_parts_for(date_string: to)
      #   return unless date?(date_parts: date_parts)

      #   begin
      #     @to = valid_date!(date_parts: date_parts)
      #   rescue ArgumentError
      #     @to = nil
      #   end
      # end

      # def from_to_dates
      #   return [] unless from && to

      #   @from_to_dates ||= date_range_for(from: from, to: to)
      # end

      # def validate_from_option
      #   return unless validate_date_option(:from)
      # end

      # def validate_to_option
      #   return unless validate_date_option(:to)
      # end

      # def validate_date_option(field)
      #   date = options[field]

      #   if date.nil?
      #     errors.add(field, :blank)
      #     return
      #   end

      #   date_parts = date_parts_for(date_string: date)
      #   return unless date?(date_parts: date_parts)

      #   begin
      #     valid_date!(date_parts: date_parts)
      #   rescue ArgumentError => e
      #     date_string = date_string_for(date_parts: date_parts)
      #     errors.add(field, "(\"#{date_string}\") is not formattable using Date.strptime(<#{field} date>, '%Y/%m/%d'): " \
      #                       "#{e.message}")
      #     return
      #   end

      #   true
      # end

      # def validate_date_range
      #   return unless from && to

      #   raise NotImplementedError
      # end

      # # This method returns the date parts for the given date string in a hash
      # # (i.e. month, day, year) IF the date string matches the DATE_CAPTURE_REGEX
      # # regex. Otherwise, it returns an empty hash.
      # def date_parts_for(date_string:)
      #   match_data = DATE_CAPTURE_REGEX.match(date_string)
      #   return {} if match_data.nil?

      #   {
      #     month: match_data[:month],
      #     day: match_data[:day],
      #     year: match_data[:year]
      #   }
      # end

      # # This method returns true if the date passes the DATE_CAPTURE_REGEX regex match
      # # in #date_parts_for and returns a non-nil hash. Otherwise, it returns false.
      # # A non-nil hash returned from #date_parts_for doesn necessarily mean the date
      # # parts will equate to a valid date when parsed, it just means the date string
      # # matched the regex. Calling #valid_date! will raise an ArgumentError if the
      # # date parts do not equate to a valid date.
      # def date?(date_parts:)
      #   !date_parts.empty?
      # end

      # def valid_date!(date_parts:)
      #   date_string = date_string_for(date_parts: date_parts)
      #   Date.strptime(date_string, '%Y/%m/%d').to_time
      # end

      # def date_string_for(date_parts:)
      #   date_parts[:year] = Time.now.year if date_parts[:year].nil?
      #   "#{date_parts[:year]}/#{date_parts[:month]}/#{date_parts[:day]}"
      # end

      # # Returns the date range for the given from and to dates.
      # def date_range_for(from:, to:)
      #   to = date_from_mneumonic(start_date: from, mneumonic: to) if mneumonic?(to)

      #   # If we're realing with dates, return a range of dates.
      #   (from..to).map(&:to_time) if [from, to].all { |date| date.is_a?(Date) }
      # end
    end
  end
end
