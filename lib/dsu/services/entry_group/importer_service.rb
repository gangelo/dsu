# frozen_string_literal: true

require 'csv'
require_relative '../../models/entry_group'

module Dsu
  module Services
    module EntryGroup
      # Expects a hash having the following format:
      # {
      #   "2023-12-29" => ["Entry 1 description", "Entry 2 description", ...],
      #   "2023-12-30" => ["Entry 1 description", ...],
      #   "2023-12-31" => ["Entry 1 description", ...]
      # }
      class ImporterService
        include Support::Fileable

        def initialize(import_entry_groups:, options: {})
          raise ArgumentError, 'Argument import_entry_groups is blank' if import_entry_groups.blank?

          @import_entry_groups = import_entry_groups
          @options = options
        end

        def call
          import!
        end

        private

        attr_reader :import_entry_groups, :options

        def import!
          import_entry_groups.each_pair do |entry_group_date, entry_descriptions|
            entry_group_for(entry_group_date).tap do |entry_group|
              entry_descriptions.each do |entry_description|
                add_entry_group_entry_if(entry_group: entry_group, entry_description: entry_description)
              end

              import_messages[entry_group.time_yyyy_mm_dd] = []

              unless entry_group.save
                entry_group.errors.full_messages.each do |error|
                  import_messages[entry_group.time_yyyy_mm_dd] << error
                end
              end
            end
          end

          import_messages
        end

        def entry_group_for(entry_group_date)
          time = Time.parse(entry_group_date).in_time_zone
          if merge?
            Models::EntryGroup.find_or_initialize(time: time)
          else
            Models::EntryGroup.new(time: time, options: options)
          end
        end

        def add_entry_group_entry_if(entry_group:, entry_description:)
          entry = Models::Entry.new(description: entry_description)
          return entry_group.entries << entry if replace?
          return if entry_group.entries.include?(entry)

          entry_group.entries << entry
        end

        def merge?
          options.fetch(:merge, true)
        end

        def replace?
          !merge?
        end

        def import_messages
          @import_messages ||= {}
        end
      end
    end
  end
end
