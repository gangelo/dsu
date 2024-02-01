# frozen_string_literal: true

require 'csv'
require_relative '../../models/entry_group'
require_relative '../../models/project'

module Dsu
  module Services
    module EntryGroup
      # Expects a hash having the following format:
      # {
      # "Project 1 Name" => {
      #     "2023-12-29" => ["Entry 1 description", "Entry 2 description", ...],
      #     "2023-12-30" => ["Entry 1 description", ...],
      #     "2023-12-31" => ["Entry 1 description", ...]
      #   },
      # "Project 2 Name" => {
      #     "2023-12-29" => ["Entry 1 description", "Entry 2 description", ...],
      #     "2023-12-30" => ["Entry 1 description", ...],
      #     "2023-12-31" => ["Entry 1 description", ...]
      #   }
      # }
      class ImporterService
        include Support::Fileable

        def initialize(import_projects:, options: {})
          raise ArgumentError, 'Argument import_projects is blank' if import_projects.blank?
          raise ArgumentError, 'Argument import_projects is not a Hash' unless import_projects.is_a?(Hash)

          raise_if_more_than_one_project(import_projects)

          @import_projects = import_projects
          @options = options
        end

        def call
          import!
        end

        private

        attr_reader :import_projects, :options

        def import!
          project_entry_groups.each_pair do |entry_group_date, entry_descriptions|
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

        def project_entry_groups
          @project_entry_groups ||= if override_project?
            import_projects.values.first || {}
          else
            import_projects.fetch(current_project_name, {})
          end
        end

        def merge?
          options.fetch(:merge, true)
        end

        def replace?
          !merge?
        end

        def override_project?
          options.fetch(:override, false)
        end

        def import_messages
          @import_messages ||= {}
        end

        def current_project_name
          @current_project_name ||= Models::Project.current_project.project_name
        end

        def raise_if_more_than_one_project(import_projects)
          return if import_projects.keys.one?

          raise ArgumentError, 'Only one project can be imported at a time'
        end
      end
    end
  end
end
