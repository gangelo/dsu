# frozen_string_literal: true

require 'time'
require 'active_support/core_ext/numeric/time'
require_relative '../../models/entry_group'
require_relative '../../support/time_formatable'

module Dsu
  module Views
    module EntryGroup
      class Edit
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
          render!
        rescue ActiveModel::ValidationError
          # TODO: Don't like how this is catching, printing and raising.
          # Change this.
          puts "Error(s) encountered: #{entry_group.errors.full_messages}"
          raise
        end
        alias render call

        private

        attr_reader :entry_group, :options

        def render!
          puts "# Editing DSU Entries for #{formatted_time(time: entry_group.time)}"
          # TODO: Display entry group entries from the previous DSU date so they can be
          # easily copied over; or, add them to the current entry group entries below as
          # a "# [+|a|add] <entry group from previous DSU entry description>" (e.g. commented
          # out) by default?
          puts ''
          puts '# [SHA/COMMAND] [DESCRIPTION]'

          entry_group_entry_lines.each { |entry_line| puts entry_line }

          puts ''
          puts '# INSTRUCTIONS:'
          puts '# ADD a DSU entry: use one of the following commands: [+|a|add] ' \
               'followed by the description.'
          puts '# EDIT a DSU entry: change the description.'
          puts '# DELETE a DSU entry: delete the entry or replace the sha with one ' \
               'of the following commands: [-|d|delete].'
          puts '# NOTE: deleting all the entries will delete the entry group file; '
          puts '#       this is preferable if this is what you want to do :)'
          puts '# REORDER a DSU entry: reorder the DSU entries in order preference.'
          puts '#'
          puts '# *** When you are done, save and close your editor ***'
        end

        def entry_group_entry_lines
          entry_group.entries.map do |entry|
            "#{entry.uuid} #{entry.description.strip}"
          end
        end
      end
    end
  end
end
