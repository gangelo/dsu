# frozen_string_literal: true

require_relative 'no_entries_to_display'

module Dsu
  module Views
    module EntryGroup
      module Shared
        class NoEntriesToDisplayForWeekOf < NoEntriesToDisplay

          def initialize(time:, options: {})
            super(times: [time.beginning_of_week, time.end_of_week], options: options)

            @time = time
          end

          private

          attr_reader :time

          # TODO: I18n.
          def message
            "(nothing to display for week of #{week_of_string}, #{time_range})"
          end

          # TODO: I18n.
          def week_of_string
            time.to_date
          end
        end
      end
    end
  end
end
