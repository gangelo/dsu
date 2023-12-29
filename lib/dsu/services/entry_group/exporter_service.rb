# frozen_string_literal: true

require 'csv'
require_relative '../../models/entry_group'
require_relative '../../support/fileable'

module Dsu
  module Services
    module EntryGroup
      class ExporterService
        include Support::Fileable

        def initialize(entry_groups:, options: {})
          raise ArgumentError, 'Argument entry_groups is blank' if entry_groups.blank?
          raise ArgumentError, 'Argument entry_groups are not all valid' unless entry_groups.all(&:valid?)

          @entry_groups = entry_groups
          @options = options
        end

        def call
          CSV.open(export_file_path, 'w') do |csv|
            csv << %i[version entry_group entry_no total_entries entry_group_entry]

            entry_groups.each do |entry_group|
              export_entry_group(entry_group: entry_group, csv: csv)
            end
          end

          export_file_path
        end

        def export_file_path
          @export_file_path ||= File.join(temp_folder, export_file_name)
        end

        private

        attr_reader :entry_groups, :options

        def export_entry_data(entry_group:, entry:, entry_index:)
          [
            entry_group.version,
            entry_group.time.to_date,
            entry_index + 1,
            entry_group.entries.count,
            entry.description
          ]
        end

        def export_entry_group(entry_group:, csv:)
          entry_group.entries.each_with_index do |entry, index|
            csv << export_entry_data(entry_group: entry_group, entry: entry, entry_index: index)
          end
        end

        def export_file_name
          "dsu-#{timestamp}-#{times.min.to_date}-thru-#{times.max.to_date}.csv"
        end

        def times
          @times ||= entry_groups.map(&:time)
        end

        def timestamp
          @timestamp ||= Time.now.in_time_zone.strftime('%Y%m%d%H%M%S')
        end
      end
    end
  end
end
