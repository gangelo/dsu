# frozen_string_literal: true

require_relative '../models/edited_entry'
require_relative '../models/entry'
require_relative '../support/colorable'
require_relative '../support/say'
require_relative '../support/time_formatable'
require_relative '../views/edited_entries/shared/errors'
require_relative '../views/shared/messages'
require_relative 'configuration_loader_service'
require_relative 'stdout_redirector_service'

module Dsu
  module Services
    class EntryGroupEditorService
      include Support::Colorable
      include Support::Say
      include Support::TimeFormatable

      def initialize(entry_group:, options: {})
        raise ArgumentError, 'entry_group is nil' if entry_group.nil?
        raise ArgumentError, 'entry_group is the wrong object type' unless entry_group.is_a?(Models::EntryGroup)
        raise ArgumentError, 'options is the wrong object type' unless options.is_a?(Hash) || options.nil?

        @entry_group = entry_group
        @options = options || {}
      end

      def call
        edit_view = render_edit_view
        edit(edit_view: edit_view)
        # NOTE: Return the original entry group object as any permanent changes
        # will have been applied to it.
        entry_group
      end

      private

      attr_reader :entry_group, :options

      # Renders the edit view to a string so we can write it to a temporary file
      # and edit it. The edits will be used to update the entry group.
      def render_edit_view
        say "Editing entry group #{formatted_time(time: entry_group.time)}...", HIGHLIGHT
        StdoutRedirectorService.call { Views::EntryGroup::Edit.new(entry_group: entry_group).render }
      end

      # Writes the temporary file contents to disk and opens it in the editor.
      def edit(edit_view:)
        Services::TempFileWriterService.new(tmp_file_content: edit_view).call do |tmp_file_path|
          if Kernel.system("${EDITOR:-#{configuration[:editor]}} #{tmp_file_path}")
            edited_entries = []
            Services::TempFileReaderService.new(tmp_file_path: tmp_file_path).call do |editor_line|
              next unless Models::EditedEntry.editable?(editor_line: editor_line)

              edited_entries << Models::EditedEntry.new(editor_line: editor_line)
            end

            process_entry_group!(edited_entries: edited_entries)
          else
            say "Failed to open temporary file in editor '#{configuration[:editor]}'; " \
                "the system error returned was: '#{$CHILD_STATUS}'.", ERROR
            say 'Either set the EDITOR environment variable ' \
                'or set the dsu editor configuration option (`$ dsu config init`).', ERROR
            say 'Run `$ dsu help config` for more information:', ERROR
          end
        end
      end

      def process_entry_group!(edited_entries:)
        if edited_entries.empty?
          entry_group.entries = []
          return entry_group.save!
        end

        raise ArgumentError, 'edited_entries is nil' if edited_entries.nil?
        raise ArgumentError, 'edited_entries is empty' if edited_entries.empty?

        # Display errors for invalid edited entries.
        invalid_entries = edited_entries.select(&:invalid?)
        Views::EditedEntries::Shared::Errors.new(edited_entries: invalid_entries).render if invalid_entries.any?

        # Display warnings for duplicate edited entries.
        duplicate_entries = duplicate_edited_entries_from(edited_entries)
        if duplicate_entries.any?
          messages = duplicate_entries.map do |edited_entry|
            "Entry contains a duplicate #description: \"#{edited_entry.short_description}\"."
          end
          header = 'The following WARNINGS were encountered; these changes were not saved:'
          Views::Shared::Messages.new(messages: messages, message_type: :warning, options: { header: header }).render
      end

        # Make sure we're not saving any duplicate entries.
        entry_group.entries = valid_unique_edited_entries_from(edited_entries).map(&:to_entry!)
        entry_group.save!
      end

      def duplicate_edited_entries_from(edited_entries)
        return [] if edited_entries.none?

        edited_entries.select(&:valid?) - edited_entries.select(&:valid?).uniq(&:description)
      end

      def valid_unique_edited_entries_from(edited_entries)
        return [] if edited_entries.none?

        edited_entries.select(&:valid?).uniq(&:description)
      end

      def configuration
        @configuration ||= ConfigurationLoaderService.new.call
      end
    end
  end
end
