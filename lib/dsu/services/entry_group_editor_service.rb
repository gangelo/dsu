# frozen_string_literal: true

require_relative '../support/colorable'
require_relative '../support/say'
require_relative '../support/time_formatable'
require_relative 'configuration_loader_service'

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
        edit!(edit_view: edit_view)
      rescue StandardError => e
        say "An error occurred while editing the entry group: #{e.message}", ERROR
      ensure
        entry_group
      end

      private

      attr_reader :entry_group, :options

      # Renders the edit view to a string so we can write it to a temporary file
      # and edit it. The edits will be used to update the entry group.
      def render_edit_view
        say "Editing entry group #{formatted_time(time: entry_group.time)}...", HIGHLIGHT
        capture_stdxxx { Views::EntryGroup::Edit.new(entry_group: entry_group).render }
      end

      # Writes the temporary file contents to disk and opens it in the editor.
      def edit!(edit_view:)
        Services::TempFileWriterService.new(tmp_file_content: edit_view).call do |tmp_file_path|
          unless Kernel.system("${EDITOR:-#{configuration[:editor]}} #{tmp_file_path}")
            say "Failed to open temporary file in editor '#{configuration[:editor]}';" \
                "the system error returned was: '#{$CHILD_STATUS}'.", ERROR
            say 'Either set the EDITOR environment variable ' \
                'or set the dsu editor configuration option (`$ dsu config init`).', ERROR
            say 'Run `$ dsu help config` for more information.', ERROR

            system('dsu help config')

            return false
          end

          update_entry_group!(tmp_file_path: tmp_file_path)
        end
      end

      def update_entry_group!(tmp_file_path:)
        entries = []
        Services::TempFileReaderService.new(tmp_file_path: tmp_file_path).call do |tmp_file_line|
          next if skip?(tmp_file_line: tmp_file_line)

          entry_info = editor_entry_info_from(tmp_file_line: tmp_file_line)
          next if entry_info.empty?
          next if delete_entry?(sha: entry_info[:sha])

          entry_info[:sha] = nil if add_entry?(sha: entry_info[:sha])

          entries << Models::Entry.new(uuid: entry_info[:sha], description: entry_info[:description])
        end

        entry_group.entries = entries
        entry_group.delete and return unless entry_group.entries?

        entry_group.save!
      end

      def delete_entry?(sha:)
        %w[- d delete].include?(sha)
      end

      def add_entry?(sha:)
        %w[+ a add].include?(sha)
      end

      def skip?(tmp_file_line:)
        ['#', nil].include? tmp_file_line[0]
      end

      def editor_entry_info_from(tmp_file_line:)
        match_data = tmp_file_line.match(/(\S+)\s(.+)/)
        {
          sha: match_data[1],
          description: match_data[2]
        }
      rescue StandardError
        {}
      end

      # https://stackoverflow.com/questions/4459330/how-do-i-temporarily-redirect-stderr-in-ruby/4459463#4459463
      def capture_stdxxx
        # The output stream must be an IO-like object. In this case we capture it in
        # an in-memory IO object so we can return the string value. You can assign any
        # IO object here.
        string_io = StringIO.new
        prev_stdout, $stdout = $stdout, string_io # rubocop:disable Style/ParallelAssignment
        prev_stderr, $stderr = $stderr, string_io # rubocop:disable Style/ParallelAssignment
        yield
        string_io.string
      ensure
        # Restore the previous value of stderr and stdout (typically equal to STDERR).
        $stdout = prev_stdout
        $stderr = prev_stderr
      end

      def configuration
        @configuration ||= ConfigurationLoaderService.new.call
      end
    end
  end
end
