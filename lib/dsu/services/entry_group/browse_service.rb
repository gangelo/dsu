# frozen_string_literal: true

require_relative '../../models/entry_group'
require_relative '../../support/time_formatable'
require_relative '../../support/times_sortable'

module Dsu
  module Services
    module EntryGroup
      # This service is responsible for returning an array of
      # sorted entry group dates.
      class BrowseService
        include Support::TimeFormatable
        include Support::TimesSortable

        def initialize(time:, options: {})
          raise ArgumentError, 'Argument time is nil' if time.nil?
          raise ArgumentError, 'Argument options is nil' if options.nil?

          @time = time
          @options = options
        end

        def call
          return [] if entry_group_times.empty?

          times_sort(times: entry_group_times, entries_display_order: entries_display_order)
        end

        private

        attr_reader :time, :options

        def entry_group_times
          @entry_group_times ||= (min_time.to_i..max_time.to_i).step(24.hours).each_with_object([]) do |time_step, times|
            time = Time.at(time_step)
            next unless include_all? || entry_group_count(time).positive?

            times << time
          end
        end

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

        def entries_display_order
          options[:entries_display_order] || default_entries_display_order
        end

        def default_entries_display_order
          :asc
        end

        def week?
          options.fetch(:browse, default_browse) == :week
        end

        def month?
          options[:browse] == :month
        end

        def year?
          options[:browse] == :year
        end

        def default_browse
          :week
        end

        def include_all?
          options.fetch(:include_all, false)
        end
      end
    end
  end
end
