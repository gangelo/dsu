# frozen_string_literal: true

require_relative '../base_cli'
require_relative '../models/entry_group'
require_relative '../support/time_formatable'
require_relative '../views/entry_group/edit'

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
        edit_entry_group(time: Time.now)
      end

      desc 'tomorrow, t',
        'Edits the DSU entries for tomorrow.'
      long_desc <<-LONG_DESC
        Edits the DSU entries for tomorrow.
      LONG_DESC
      def tomorrow
        edit_entry_group(time: Time.now.tomorrow)
      end

      desc 'yesterday, y',
        'Edits the DSU entries for yesterday.'
      long_desc <<-LONG_DESC
        Edits the DSU entries for yesterday.
      LONG_DESC
      def yesterday
        edit_entry_group(time: Time.now.yesterday)
      end

      desc 'date, d DATE',
        'Edits the DSU entries for DATE.'
      long_desc <<-LONG_DESC
        Edits the DSU entries for DATE.

        \x5 #{date_option_description}
      LONG_DESC
      def date(date)
        edit_entry_group(time: Time.parse(date))
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
        # system("${EDITOR:-nano} #{file_path}")

        output = capture_stdxxx do
          Views::EntryGroup::Edit.new(entry_group: entry_group).render
        end
        say output, SUCCESS
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
