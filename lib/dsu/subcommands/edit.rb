# frozen_string_literal: true

require_relative '../base_cli'
require_relative '../models/entry_group'
require_relative '../services/temp_file_reader_service'
require_relative '../services/temp_file_writer_service'
require_relative '../support/time_formatable'
require_relative '../views/entry_group/edit'
require_relative '../views/entry_group/show'

module Dsu
  module Subcommands
    class Edit < Dsu::BaseCLI
      include Support::TimeFormatable

      map %w[d] => :date
      map %w[n] => :today
      map %w[t] => :tomorrow
      map %w[y] => :yesterday

      desc 'today, n',
        'Edits the DSU entries for today.'
      long_desc <<-LONG_DESC
       Edits the DSU entries for today.
      LONG_DESC
      def today
        Views::EntryGroup::Show.new(entry_group: edit_entry_group(time: Time.now)).render
      end

      desc 'tomorrow, t',
        'Edits the DSU entries for tomorrow.'
      long_desc <<-LONG_DESC
        Edits the DSU entries for tomorrow.
      LONG_DESC
      def tomorrow
        Views::EntryGroup::Show.new(entry_group: edit_entry_group(time: Time.now.tomorrow)).render
      end

      desc 'yesterday, y',
        'Edits the DSU entries for yesterday.'
      long_desc <<-LONG_DESC
        Edits the DSU entries for yesterday.
      LONG_DESC
      def yesterday
        Views::EntryGroup::Show.new(entry_group: edit_entry_group(time: Time.now.yesterday)).render
      end

      desc 'date, d DATE',
        'Edits the DSU entries for DATE.'
      long_desc <<-LONG_DESC
        Edits the DSU entries for DATE.

        \x5 #{date_option_description}
      LONG_DESC
      def date(date)
        Views::EntryGroup::Show.new(entry_group: edit_entry_group(time: Time.parse(date))).render
      rescue ArgumentError => e
        say "Error: #{e.message}", ERROR
        exit 1
      end

      private

      def edit_entry_group(time:)
        formatted_time = formatted_time(time: time)
        unless Models::EntryGroup.exists?(time: time)
          say "No DSU entries exist for #{formatted_time}"
          exit 1
        end

        say "Editing DSU entries for #{formatted_time}..."
        entry_group = Models::EntryGroup.load(time: time)

        # This renders the view to a string...
        output = capture_stdxxx do
          Views::EntryGroup::Edit.new(entry_group: entry_group).render
        end
        # ...which is then written to a temp file.
        Services::TempFileWriterService.new(temp_file_content: output).call do |temp_file_path|
          system("${EDITOR:-#{configuration[:editor]}} #{temp_file_path}")
          entries = []
          Services::TempFileReaderService.new(temp_file_path: temp_file_path).call do |temp_file_line|
            # Skip comments and blank lines.
            next if ['#', nil].include? temp_file_line[0]

            match_data = temp_file_line.match(/(\S+)\s(.+)/)
            # TODO: Error handling if match_data is nil.
            entry_sha = match_data[1]
            entry_description = match_data[2]

            next if %w[- d delete].include?(entry_sha) # delete the entry

            entry_sha = nil if %w[+ a add].include?(entry_sha) # add the new entry
            entries << Models::Entry.new(uuid: entry_sha, description: entry_description)
          end

          if entries.empty?
            say 'TODO: If the user deleted all entries, delete the entry group.'
          else
            entry_group.entries = entries
            entry_group.save!
          end
        end
        entry_group
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
    end
  end
end
