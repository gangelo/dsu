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

          @entry_groups = entry_groups
          @options = options
        end

        def call
          CSV.open(export_file_name, 'w') do |csv|
            csv << %i[version entry_group entry_no total_entries entry_group_entry]

            entry_groups.each do |entry_group|
              next unless entry_group.exist?

              entry_group.entries.each_with_index do |entry, index|
                csv << [
                  entry_group.version,
                  entry_group.time.to_date,
                  index + 1,
                  entry_group.entries.count,
                  entry.description
                ]
              end
            end
          end

          export_file_name
        end

        def export_file_name
          @export_file_name ||= begin
            file_name = "dsu-#{export_timestamp}-#{times.min.to_date}-thru-#{times.max.to_date}.csv"
            File.join(temp_folder, file_name)
          end
        end

        private

        attr_reader :entry_groups, :options

        def times
          @times ||= entry_groups.map(&:time)
        end

        def export_timestamp
          Time.now.in_time_zone.strftime('%Y%m%d%H%M%S')
        end
      end
    end
  end
end
