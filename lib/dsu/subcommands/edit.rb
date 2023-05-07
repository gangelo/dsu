# frozen_string_literal: true

require_relative '../base_cli'

module Dsu
  module Subcommands
    class Edit < Dsu::BaseCLI
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
        time = Time.now
        sorted_dsu_times_for(times: [time, time.yesterday]).each do |t|
          view_entry_group(time: t)
          puts
        end
      end

      desc 'tomorrow, t',
        'Edits the DSU entries for tomorrow.'
      long_desc <<-LONG_DESC
        Edits the DSU entries for tomorrow.
      LONG_DESC
      def tomorrow
        time = Time.now
        sorted_dsu_times_for(times: [time.tomorrow, time]).each do |t|
          view_entry_group(time: t)
          puts
        end
      end

      desc 'yesterday, y',
        'Edits the DSU entries for yesterday.'
      long_desc <<-LONG_DESC
        Edits the DSU entries for yesterday.
      LONG_DESC
      def yesterday
        time = Time.now
        sorted_dsu_times_for(times: [time.yesterday, time.yesterday.yesterday]).each do |t|
          view_entry_group(time: t)
          puts
        end
      end

      desc 'date, d DATE',
        'Edits the DSU entries for DATE.'
      long_desc <<-LONG_DESC
        Edits the DSU entries for DATE.

        \x5 #{date_option_description}
      LONG_DESC
      def date(date)
        time = Time.parse(date)
        sorted_dsu_times_for(times: [time, time.yesterday]).each do |t|
          view_entry_group(time: t)
          puts
        end
      rescue ArgumentError => e
        say "Error: #{e.message}", ERROR
        exit 1
      end
    end
  end
end
