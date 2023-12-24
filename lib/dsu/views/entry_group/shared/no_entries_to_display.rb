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

          # TODO: I18n.
          def render
            puts render_as_string
          end

          def render_as_string
            apply_theme(message, theme_color: color_theme.info)
          end

          private

          attr_reader :times, :options

          def message
            "(nothing to display for #{time_range})"
          end

          def time_range
            "#{formatted_time(time: times.min)} " \
              "through #{formatted_time(time: times.max)}"
          end

          def color_theme
            @color_theme ||= Models::ColorTheme.current_or_default
          end
        end
      end
    end
  end
end
