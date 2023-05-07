# frozen_string_literal: true

module Dsu
  module Support
    module EntryGroupViewable
      module_function

      def view_entry_group(time:)
        entry_group = if Models::EntryGroup.exists?(time: time)
          entry_group_json = Services::EntryGroupReaderService.new(time: time).call
          Services::EntryGroupHydratorService.new(entry_group_json: entry_group_json).call
        else
          Models::EntryGroup.new(time: time)
        end
        Views::EntryGroup::Show.new(entry_group: entry_group).display
      end
    end
  end
end
