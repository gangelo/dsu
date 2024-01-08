# frozen_string_literal: true

module Dsu
  module Views
    module EntryGroup
      class List
        def initialize(presenter:)
          @presenter = presenter
        end

        def render
          return presenter.display_nothing_to_list_message if presenter.nothing_to_list?

          presenter.render
        end

        private

        attr_reader :presenter
      end
    end
  end
end
