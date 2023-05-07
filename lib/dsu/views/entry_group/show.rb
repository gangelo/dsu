# frozen_string_literal: true

require 'time'
require 'tzinfo'
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
          # Just in case the entry group is invalid, we'll
          # validate it before displaying it.
          entry_group.validate!
          display_entry_group!
        rescue ActiveModel::ValidationError
          puts "Error(s) encountered: #{entry_group.errors.full_messages}"
          raise
        end
        alias display call

        private

        attr_reader :entry_group, :options

        def display_entry_group!
          say formatted_time(time: entry_group.time), HIGHLIGHT
          say('(no entries available for this day)') and return if entry_group.entries.empty?

          entry_group.entries.each_with_index do |entry, index|
            prefix = "#{format('%03s', index + 1)}. #{entry.uuid}"
            description = colorize_string(string: entry.description, mode: :bold)
            say "#{prefix} #{description}"
          end
        end
      end
    end
  end
end
