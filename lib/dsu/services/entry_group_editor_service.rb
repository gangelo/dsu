# frozen_string_literal: true

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
        edit edit_view
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

      # Writes the temporary file contents to disk and opens it in the editor
      # for editing. It then copies the changes to the entry group and writes
      # the changes to the entry group file.
      def edit(edit_view)
        entry_group_with_edits = Models::EntryGroup.new(time: entry_group.time)

        Services::TempFileWriterService.new(tmp_file_content: edit_view).call do |tmp_file_path|
          if Kernel.system("${EDITOR:-#{configuration[:editor]}} #{tmp_file_path}")
            Services::TempFileReaderService.new(tmp_file_path: tmp_file_path).call do |editor_line|
              next unless process_description?(editor_line)

              entry_group_with_edits.entries << Models::Entry.new(description: editor_line)
            end

            process_entry_group!(entry_group_with_edits)
          else
            say "Failed to open temporary file in editor '#{configuration[:editor]}'; " \
                "the system error returned was: '#{$CHILD_STATUS}'.", ERROR
            say 'Either set the EDITOR environment variable ' \
                'or set the dsu editor configuration option (`$ dsu config init`).', ERROR
            say 'Run `$ dsu help config` for more information:', ERROR
          end
        end
      end

      def process_entry_group!(entry_group_with_edits)
        if entry_group_with_edits.entries.empty?
          entry_group.delete!
          return
        end

        if entry_group_with_edits.invalid?
          header = 'The following ERRORS were encountered; these changes were not saved:'
          messages = entry_group_with_edits.errors.full_messages
          Views::Shared::Messages.new(messages: messages, message_type: :error, options: { header: header }).render
        end

        # Make sure we're saving only valid, unique entries.
        entry_group.entries = entry_group_with_edits.valid_unique_entries
        entry_group.save!
      end

      def process_description?(description)
        description = Models::Entry.clean_description(description)
        !(description.blank? || description[0] == '#')
      end

      def configuration
        @configuration ||= ConfigurationLoaderService.new.call
      end
    end
  end
end
