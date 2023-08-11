# frozen_string_literal: true

require_relative '../../../models/color_theme'
require_relative '../../../support/color_themable'
require_relative '../../../support/time_formatable'

module Dsu
  module Views
    module EntryGroup
      module Shared
        class NoEntriesToDisplay
          include Support::ColorThemable
          include Support::TimeFormatable

          def initialize(times:, options: {})
            raise ArgumentError, 'times must be an Array' unless times.is_a?(Array)
            raise ArgumentError, 'times must contain Time objects' unless times.all?(Time)
            raise ArgumentError, 'options must be a Hash' unless options.is_a?(Hash) || options.nil?

            @times = times
            @options = options || {}
          end

          def render
            entry_group_times.sort!
            time_range = "#{formatted_time(time: times.first)} " \
                         "through #{formatted_time(time: times.last)}"
            message = "(nothing to display for #{time_range})"
            puts apply_theme(message, theme_color: color_theme.info)
          end

          private

          def color_theme
            @color_theme ||= Models::ColorTheme.current_or_default
          end
        end
      end
    end
  end
end
