# frozen_string_literal: true

require 'csv'
require_relative '../../models/entry_group'
require_relative '../../support/fileable'
require_relative '../../support/transform_project_name'

module Dsu
  module Services
    module EntryGroup
      # ExporterService exports entry groups to a CSV file.
      # NOTE: This class exports all entries passed to it. It does not filter
      # entries based on optional options[:time] that may be passed to it.
      # Rather, times are used to determine the export file name only.
      class ExporterService
        include Support::Fileable
        include Support::TransformProjectName

        def initialize(project_name:, entry_groups:, options: {})
          raise ArgumentError, 'Argument project_name is blank' if project_name.blank?
          raise ArgumentError, 'Argument entry_groups is blank' if entry_groups.blank?
          raise ArgumentError, 'Argument entry_groups are not all valid' unless entry_groups.all?(&:valid?)

          validate_entry_group_entries_present! entry_groups

          @project_name = project_name
          @entry_groups = entry_groups
          @options = options
        end

        def call
          CSV.open(export_file_path, 'w') do |csv|
            csv << %i[project_name version entry_group entry_no total_entries entry_group_entry]

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

        attr_reader :project_name, :entry_groups, :options

        def export_entry_data(entry_group:, entry:, entry_index:)
          [
            project_name,
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
          transformed_file_name = transform_project_name project_name, options: options
          "dsu-export-#{transformed_file_name}-" \
            "#{timestamp}-#{export_scope}-#{times.min.to_date}-thru-#{times.max.to_date}.csv"
        end

        def export_scope
          return 'all-entry-groups' unless options.fetch(:times, nil)

          'entry-groups'
        end

        def times
          @times ||= options.fetch(:times, entry_groups.map(&:time))
        end

        def timestamp
          @timestamp ||= Time.now.in_time_zone.strftime('%Y%m%d%H%M%S')
        end

        def validate_entry_group_entries_present!(entry_groups)
          entry_groups.each do |entry_group|
            next if entry_group.entries.present?

            raise ArgumentError, "Argument entry_groups entry group for #{entry_group.time_yyyy_mm_dd} has no entries"
          end
        end
      end
    end
  end
end
