# frozen_string_literal: true

require_relative '../../services/entry_group/exporter_service'

module Dsu
  module Presenters
    module Export
      module ServiceCallable
        private

        def exporter_service_call
          @exporter_service_call ||= begin
            exporter_service = Services::EntryGroup::ExporterService.new(entry_groups: entry_groups, options: options)
            exporter_service.call
          end
        end
      end
    end
  end
end
