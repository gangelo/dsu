# frozen_string_literal: true

require_relative '../../services/entry_group/importer_service'

module Dsu
  module Presenters
    module Import
      module ServiceCallable
        private

        def importer_service_call
          @importer_service_call ||= begin
            importer_service = Services::EntryGroup::ImporterService.new(import_entry_groups: import_entry_groups,
              options: options)
            importer_service.call
          end
        end
      end
    end
  end
end
