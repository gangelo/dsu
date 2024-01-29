# frozen_string_literal: true

require_relative '../../models/entry_group'
require_relative '../../services/entry_group/importer_service'
require_relative '../base_presenter_ex'
require_relative 'import_file'

module Dsu
  module Presenters
    module Import
      class AllPresenter < BasePresenterEx
        include ImportFile

        attr_reader :import_messages

        def initialize(import_file_path:, options: {})
          super(options: options)

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

        attr_reader :import_file_path

        def import_entry_groups
          @import_entry_groups ||= CSV.foreach(import_file_path,
            headers: true, header_converters: :symbol).with_object({}) do |entry_group_entry, entry_groups_hash|
            next unless entry_group_entry[:version].to_i == Dsu::Migration::VERSION
            # TODO: Later on, when we export/import all projects, we'll need to
            # remove this and refactor lib/dsu/services/entry_group/importer_service.rb
            # to import all projects.
            next unless entry_group_entry[:project_name] == project_name

            project_name = entry_group_entry[:project_name]
            entry_groups_hash[project_name] = {} unless entry_groups_hash.key?(project_name)

            Date.parse(entry_group_entry[:entry_group]).to_s.tap do |time|
              entry_groups_hash[project_name][time] = [] unless entry_groups_hash.key?(time)
              entry_groups_hash[project_name][time] << entry_group_entry[:entry_group_entry]
            end
          end
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
