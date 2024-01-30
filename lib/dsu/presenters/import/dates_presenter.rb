# frozen_string_literal: true

require_relative '../../models/entry_group'
require_relative '../../services/entry_group/importer_service'
require_relative '../base_presenter_ex'
require_relative 'import_file'

module Dsu
  module Presenters
    module Import
      class DatesPresenter < BasePresenterEx
        include ImportFile

        attr_reader :from, :to, :import_file_path, :import_messages

        def initialize(from:, to:, import_file_path:, options: {})
          super(options: options)

          @from = from.beginning_of_day
          @to = to.end_of_day
          @import_file_path = import_file_path
        end

        def respond(response:)
          return false unless response

          @import_messages = importer_service.call
        end

        def nothing_to_import?
          import_entry_groups_count.zero?
        end

        def import_entry_groups_count
          import_entry_groups[project_name]&.count || 0
        end

        def project_name
          @project_name ||= Models::Project.current_project.project_name
        end

        private

        def import_entry_groups
          @import_entry_groups ||= CSV.foreach(import_file_path,
            headers: true, header_converters: :symbol).with_object({}) do |entry_group_entry, entry_groups_hash|
            next unless entry_group_entry[:version].to_i == Dsu::Migration::VERSION
            # TODO: Later on, when we export/import all projects, we'll need to
            # remove this and refactor lib/dsu/services/entry_group/importer_service.rb
            # to import all projects.
            next unless entry_group_entry[:project_name] == project_name

            entry_group_time = middle_of_day_for(entry_group_entry[:entry_group])
            next unless entry_group_time.to_date.between?(from.to_date, to.to_date)

            project_name = entry_group_entry[:project_name]
            entry_groups_hash[project_name] = {} unless entry_groups_hash.key?(project_name)

            entry_group_time.to_date.to_s.tap do |time|
              entry_groups_hash[project_name][time] = [] unless entry_groups_hash[project_name].key?(time)
              entry_groups_hash[project_name][time] << entry_group_entry[:entry_group_entry]
            end
          end
        end

        def middle_of_day_for(date_string)
          Time.parse(date_string).in_time_zone.middle_of_day
        end

        def importer_service
          @importer_service ||= Services::EntryGroup::ImporterService.new(
            import_projects: import_entry_groups, options: options
          )
        end
      end
    end
  end
end
