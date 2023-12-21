# frozen_string_literal: true

require_relative 'no_entries_to_display'

module Dsu
  module Views
    module EntryGroup
      module Shared
        class NoEntriesToDisplayForYearOf < NoEntriesToDisplay
          def initialize(time:, options: {})
            super(times: [time.beginning_of_year, time.end_of_year], options: options)

            @time = time
          end

          private

          attr_reader :time

          # TODO: I18n.
          def message
            "(nothing to display for the year of #{year_string}, #{time_range})"
          end

          # TODO: I18n.
          def year_string
            time.year
          end
        end
      end
    end
  end
end
