# frozen_string_literal: true

require_relative 'no_entries_to_display'

module Dsu
  module Views
    module EntryGroup
      module Shared
        class NoEntriesToDisplayForMonthOf < NoEntriesToDisplay
          def initialize(time:, options: {})
            super(times: [time.beginning_of_month, time.end_of_month], options: options)

            @time = time
          end

          private

          attr_reader :time

          # TODO: I18n.
          def message
            "(nothing to display for the month of #{month_string}, #{time_range})"
          end

          def month_string
            I18n.l(time, format: '%B')
          end
        end
      end
    end
  end
end
