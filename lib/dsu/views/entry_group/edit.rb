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

        def render
          puts render_as_string
        end

        def render_as_string
          # Just in case the entry group is invalid, we'll validate it before displaying it.
          entry_group.validate!

          # TODO: Display entry group entries from the previous DSU date so they can be
          # easily copied over; or, add them to the current entry group entries below as
          # a "# [+|a|add] <entry group from previous DSU entry description>"
          # (e.g. commented out) by default?

          <<~EDIT_VIEW
            # Editing DSU Entries for #{formatted_time(time: entry_group.time)}
            # [ENTRY DESCRIPTION]

            #{ entry_group_entry_lines.each(&:strip).join("\n") }

            # INSTRUCTIONS:
            #    ADD a DSU entry: type an ENTRY DESCRIPTION on a new line.
            #   EDIT a DSU entry: change the existing ENTRY DESCRIPTION.
            # DELETE a DSU entry: delete the ENTRY DESCRIPTION.
            #  NOTE: deleting all of the ENTRY DESCRIPTIONs will delete the entry group file;
            #        this is preferable if this is what you want to do :)
            # REORDER a DSU entry: reorder the ENTRY DESCRIPTIONs in order preference.
            #
            # *** When you are done, save and close your editor ***
          EDIT_VIEW
        end

        private

        attr_reader :entry_group, :options

        def entry_group_entry_lines
          entry_group.entries.map(&:description)
        end
      end
    end
  end
end
