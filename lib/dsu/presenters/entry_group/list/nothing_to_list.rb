# frozen_string_literal: true

module Dsu
  module Presenters
    module EntryGroup
      module List
        module NothingToList
          def nothing_to_list?
            entry_groups.none?
          end
        end
      end
    end
  end
end
