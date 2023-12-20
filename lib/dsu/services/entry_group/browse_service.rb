# frozen_string_literal: true

require_relative '../../models/entry_group'
require_relative '../../support/time_formatable'

module Dsu
  module Services
    module EntryGroup
      # This service is responsible for returning an array of hashes
      # that represent entry groups (represented by entry group time)
      # and entry group entry counts. (e.g. [ { "2023-01-31" => 3 }, ... ])
      # This array of hashes can be used as part of the greater functionality
      # of browsing through entry groups using "next" and "previous" commands.
      class BrowseService
        include Support::TimeFormatable

        def initialize(time:, options: {})
          raise ArgumentError, 'Argument time is nil' if time.nil?

          @time = time
          @options = options
        end

        def call
          return [] if times.empty?

          (min_time.to_i..max_time.to_i).step(24.hours).each_with_object([]) do |time_step, entry_group_times|
            time = Time.at(time_step)
            entry_count = entry_group_count(time)
            next unless include_all? || entry_count.positive?

            entry_group_times << { yyyy_mm_dd(time: time) => entry_count }
          end
        end

        private

        attr_reader :time, :options

        def entry_group_count(time)
          entry_group = Models::EntryGroup.find_or_initialize(time: time)
          entry_group.persisted? ? entry_group.entries.count : 0
        end

        def min_time
          @min_time ||= if week?
            time.beginning_of_week
          elsif month?
            time.beginning_of_month
          elsif year?
            time.beginning_of_year
          end
        end

        def max_time
          @max_time ||= if week?
            time.end_of_week
          elsif month?
            time.end_of_month
          elsif year?
            time.end_of_year
          end
        end

        def times
          @times ||= Models::EntryGroup.entry_group_times(between: [min_time, max_time], options: options)
        end

        def include_all?
          options[:include_all] || false
        end

        def week?
          options.fetch(:week, false)
        end

        def month?
          options.fetch(:month, false)
        end

        def year?
          options.fetch(:year, false)
        end
      end
    end
  end
end
