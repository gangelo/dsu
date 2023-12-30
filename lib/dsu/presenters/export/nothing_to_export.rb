# frozen_string_literal: true

module Dsu
  module Presenters
    module Export
      module NothingToExport
        def nothing_to_export?
          entry_groups.empty?
        end
      end
    end
  end
end
