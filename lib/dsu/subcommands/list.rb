# frozen_string_literal: true

require_relative '../base_cli'
require_relative '../support/command_options/dsu_times'

module Dsu
  module Subcommands
    class List < Dsu::BaseCLI
      include Support::CommandOptions::DsuTimes

      map %w[d] => :date
      map %w[dd] => :dates
      map %w[n] => :today
      map %w[t] => :tomorrow
      map %w[y] => :yesterday

      desc 'today, n',
        'Displays the DSU entries for today'
      long_desc <<-LONG_DESC
        Displays the DSU entries for today. This command has no options.
      LONG_DESC
      def today
        time = Time.now
        sorted_dsu_times_for(times: [time, time.yesterday]).each do |t|
          view_entry_group(time: t)
          puts
        end
      end

      desc 'tomorrow, t',
        'Displays the DSU entries for tomorrow'
      long_desc <<-LONG_DESC
        Displays the DSU entries for tomorrow. This command has no options.
      LONG_DESC
      def tomorrow
        time = Time.now
        sorted_dsu_times_for(times: [time.tomorrow, time]).each do |t|
          view_entry_group(time: t)
          puts
        end
      end

      desc 'yesterday, y',
        'Displays the DSU entries for yesterday'
      long_desc <<-LONG_DESC
        Displays the DSU entries for yesterday. This command has no options.
      LONG_DESC
      def yesterday
        time = Time.now
        sorted_dsu_times_for(times: [time.yesterday, time.yesterday.yesterday]).each do |t|
          view_entry_group(time: t)
          puts
        end
      end

      desc 'date, d DATE',
        'Displays the DSU entries for DATE'
      long_desc <<-LONG_DESC
      Displays the DSU entries for DATE.
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

      desc 'dates, dd OPTIONS',
        'Displays the DSU entries for the OPTIONS provided'
      long_desc <<~LONG_DESC
        NAME
        \x5
        `dsu dates|dd OPTIONS` -- will display the DSU entries for the OPTIONS provided.

        SYNOPSIS
        \x5
        `dsu dates|dd OPTIONS`

        OPTIONS:
        \x5
        -f|--from DATE|MNEMONIC: ?.

        \x5
        -t|--to DATE|MNEMONIC: ?.

        \x5
        #{date_option_description}

        \x5
        #{mneumonic_option_description}
      LONG_DESC
      # -f, --from FROM [DATE|MNEMONIC] (e.g. -f, --from 1/1[/yyy]|n|t|y|today|tomorrow|yesterday)
      option :from, type: :string, aliases: '-f', banner: 'DATE|MNEMONIC'
      # -t, --to TO [DATE|MNEMONIC] (e.g. -t, --to 1/1[/yyy]|n|t|y|today|tomorrow|yesterday)
      option :to, type: :string, aliases: '-t', banner: 'DATE|MNEMONIC'

      # Exclude dates that have no DSU entries.
      option :exclude_blank, type: :boolean, aliases: '-x', default: false
      def dates
        times = dsu_times_from!(from_command_option: options[:from], to_command_option: options[:to])
        # Note special sort here, unlike the other commands where rules for
        # displaying DSU entries are applied; this is more of a list command.
        times_sort(times: times, entries_display_order: entries_display_order).each do |t|
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
