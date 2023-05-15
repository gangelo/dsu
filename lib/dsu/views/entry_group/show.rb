# frozen_string_literal: true

require 'time'
require 'active_support/core_ext/numeric/time'
require_relative '../../models/entry_group'
require_relative '../../support/colorable'
require_relative '../../support/say'
require_relative '../../support/time_formatable'

module Dsu
  module Views
    module EntryGroup
      class Show
        include Support::Colorable
        include Support::Say
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
          render_entry_group!
        end
        alias render call

        private

        attr_reader :entry_group, :options

        def render_entry_group!
          say formatted_time(time: entry_group.time), HIGHLIGHT
          say('(no entries available for this day)') and return if entry_group.entries.empty?

          entry_group.entries.each_with_index do |entry, index|
            prefix = "#{format('%03s', index + 1)}. "
            description = colorize_string(string: entry.description, mode: :bold)
            entry_info = "#{prefix} #{description}"
            entry_info = "#{entry_info} (validation failed: #{entry_errors(entry_group_deleter_service)})" unless entry.valid?
            say entry_info
          end
        end

        def entry_errors(entry)
          entry.errors.full_messages.join(', ')
        end
      end
    end
  end
end
