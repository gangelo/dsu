# frozen_string_literal: true

require 'time'
require 'active_support/core_ext/numeric/time'
require_relative '../../models/entry_group'
require_relative '../../support/color_themable'
require_relative '../../support/time_formatable'

module Dsu
  module Views
    module EntryGroup
      class Show
        include Support::ColorThemable
        include Support::TimeFormatable

        def initialize(entry_group:, options: {})
          raise ArgumentError, 'entry_group is nil' if entry_group.nil?
          raise ArgumentError, 'entry_group is the wrong object type' unless entry_group.is_a?(Models::EntryGroup)
          raise ArgumentError, 'options is nil' if options.nil?
          raise ArgumentError, 'options is the wrong object type' unless options.is_a?(Hash)

          @entry_group = entry_group
          @options = options || {}
        end

        def call
          render!
        end
        alias render call

        private

        attr_reader :entry_group, :options

        def render!
          entry_group_presenter = entry_group.presenter
          puts entry_group_presenter.formatted_time

          entry_group.validate!
          puts entry_group_presenter.no_entries_available and return if entry_group.entries.empty?

          entry_group.entries.each_with_index do |entry, index|
            entry_presenter = entry.presenter
            puts entry_presenter.formatted_description_with_index(index: index)
          end
        rescue ActiveModel::ValidationError
          puts apply_color_theme(errors(entry_group), color_theme_color: color_theme.error)
        end

        def errors(model)
          model.errors.full_messages.join(', ')
        end

        def color_theme
          @color_theme ||= Models::ColorTheme.current_or_default
        end
      end
    end
  end
end
