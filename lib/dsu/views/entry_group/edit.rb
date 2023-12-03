# frozen_string_literal: true

require_relative '../../models/configuration'
require_relative '../../models/entry_group'

module Dsu
  module Views
    module EntryGroup
      # TODO: I18n this class.
      class Edit
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

          <<~EDIT_VIEW
            #{banner_line}
            # Editing DSU Entries for #{entry_group.time_formatted}
            #{banner_line}

            #{entry_group_view&.chomp}

            #{banner_line}
            # INSTRUCTIONS
            #{banner_line}
            #    ADD a DSU entry: type an ENTRY DESCRIPTION on a new line.
            #   EDIT a DSU entry: change the existing ENTRY DESCRIPTION.
            # DELETE a DSU entry: delete the ENTRY DESCRIPTION.
            #  NOTE: deleting all of the ENTRY DESCRIPTIONs will delete the entry group file;
            #        this is preferable if this is what you want to do :)
            # REORDER a DSU entry: reorder the ENTRY DESCRIPTIONs in order preference.
            #
            # *** When you are done, save and close your editor ***
            #{banner_line}
          EDIT_VIEW
        end

        private

        attr_reader :entry_group, :options

        def time
          @time ||= entry_group.time
        end

        def banner_line
          '#' * 80
        end

        def entry_group_view
          return entry_group_entry_lines if entry_group.entries.any?
          return previous_entry_group_entry_lines if carry_over_entries_to_today? && previous_entry_group?

          <<~EDIT_VIEW
            #{banner_line}
            # ENTER DSU ENTRIES BELOW
            #{banner_line}

          EDIT_VIEW
        end

        def entry_group_entry_lines
          raise 'No entries in entry group' if entry_group.entries.empty?

          <<~EDIT_VIEW
            #{banner_line}
            # DSU ENTRIES
            #{banner_line}

            #{entry_group.entries.map(&:description).join("\n").chomp}
          EDIT_VIEW
        end

        def previous_entry_group_entry_lines
          raise 'carry_over_entries_to_today? is false' unless carry_over_entries_to_today?
          raise 'Entries exist in entry_group' if entry_group.entries.any?
          raise 'No previous entry group exists' unless previous_entry_group?

          <<~EDIT_VIEW
            #{banner_line}
            # PREVIOUS DSU ENTRIES FROM #{previous_entry_group.time_formatted}
            #{banner_line}

            #{previous_entry_group.entries.map(&:description).join("\n").chomp}
          EDIT_VIEW
        end

        def previous_entry_group?
          previous_entry_group&.entries&.present?
        end

        def previous_entry_group
          # Go back a max of 7 days to find the previous entry group.
          # TODO: Make this configurable or accept an option?
          @previous_entry_group ||= (1..7).each do |days|
            t = time.days_ago(days)
            return Models::EntryGroup.find(time: t) if Models::EntryGroup.exist?(time: t)
          end
          nil
        end

        def carry_over_entries_to_today?
          Models::Configuration.new.merge(options).carry_over_entries_to_today?
        end
      end
    end
  end
end
