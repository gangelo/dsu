# frozen_string_literal: true

require_relative '../../models/entry_group'
require_relative '../../services/entry_group/exporter_service'
require_relative '../base_presenter_ex'

module Dsu
  module Presenters
    module Export
      class DatesPresenter < BasePresenterEx
        attr_reader :export_file_path

        def initialize(from:, to:, options: {})
          super(options: options)

          @from = from
          @to = to

          self.options[:times] = [from, to]
        end

        def respond(response:)
          return false unless response

          @export_file_path = exporter_service.call
        end

        def nothing_to_export?
          entry_groups.empty?
        end

        def entry_group_count
          entry_groups&.count || 0
        end

        private

        attr_reader :from, :to, :options

        def entry_groups
          Models::EntryGroup.entry_groups(between: [from, to])
        end

        def exporter_service
          Services::EntryGroup::ExporterService.new(project_name: project_name,
            entry_groups: entry_groups, options: options)
        end

        def project_name
          @project_name ||= Models::Project.current_project.project_name
        end
      end
    end
  end
end
