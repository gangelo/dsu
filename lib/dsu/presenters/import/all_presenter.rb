# frozen_string_literal: true

require_relative '../../models/entry_group'
require_relative '../../services/entry_group/importer_service'
require_relative '../base_presenter_ex'
require_relative 'import_entry'
require_relative 'import_file'

module Dsu
  module Presenters
    module Import
      class AllPresenter < BasePresenterEx
        include ImportEntry
        include ImportFile

        attr_reader :import_file_path, :import_messages

        def initialize(import_file_path:, options: {})
          super(options: options)

          @import_file_path = import_file_path
        end

        def respond
          @import_messages = importer_service.call
        end

        def project_name
          @project_name ||= Models::Project.current_project.project_name
        end

        private

        def import_entry_groups
          @import_entry_groups ||= CSV.foreach(import_file_path,
            headers: true, header_converters: :symbol).with_object({}) do |entry_group_entry, entry_groups_hash|
            next unless import_entry?(entry_group_entry)

            project_name = entry_group_entry[:project_name]
            entry_groups_hash[project_name] = {} unless entry_groups_hash.key?(project_name)

            Date.parse(entry_group_entry[:entry_group]).to_s.tap do |time|
              entry_groups_hash[project_name][time] = [] unless entry_groups_hash[project_name].key?(time)
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
