# frozen_string_literal: true

require 'English'
require_relative '../base_cli'
require_relative '../models/entry_group'
require_relative '../services/temp_file_reader_service'
require_relative '../services/temp_file_writer_service'
#require_relative '../support/time_formatable'
require_relative '../views/entry_group/edit'
require_relative '../views/entry_group/show'

module Dsu
  module Subcommands
    class Edit < Dsu::BaseCLI
      #include Support::TimeFormatable

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
        entry_group = edit_entry_group(time: Time.now)
        Views::EntryGroup::Show.new(entry_group: entry_group).render
      end

      desc 'tomorrow, t',
        'Edits the DSU entries for tomorrow.'
      long_desc <<-LONG_DESC
        Edits the DSU entries for tomorrow.
      LONG_DESC
      def tomorrow
        entry_group = edit_entry_group(time: Time.now.tomorrow)
        Views::EntryGroup::Show.new(entry_group: entry_group).render
      end

      desc 'yesterday, y',
        'Edits the DSU entries for yesterday.'
      long_desc <<-LONG_DESC
        Edits the DSU entries for yesterday.
      LONG_DESC
      def yesterday
        entry_group = edit_entry_group(time: Time.now.yesterday)
        Views::EntryGroup::Show.new(entry_group: entry_group).render
      end

      desc 'date, d DATE',
        'Edits the DSU entries for DATE.'
      long_desc <<-LONG_DESC
        Edits the DSU entries for DATE.

        \x5 #{date_option_description}
      LONG_DESC
      def date(date)
        entry_group = edit_entry_group(time: Time.parse(date))
        Views::EntryGroup::Show.new(entry_group: entry_group).render
      rescue ArgumentError => e
        say "Error: #{e.message}", ERROR
        exit 1
      end
    end
  end
end
