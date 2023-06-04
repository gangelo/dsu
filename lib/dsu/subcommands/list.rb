# frozen_string_literal: true

require_relative '../base_cli'
require_relative '../support/command_options/dsu_times'
require_relative '../support/time_formatable'

module Dsu
  module Subcommands
    class List < Dsu::BaseCLI
      include Support::CommandOptions::DsuTimes
      include Support::TimeFormatable

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
        times = sorted_dsu_times_for(times: [time, time.yesterday])
        view_list_for(times: times)
      end

      desc 'tomorrow, t',
        'Displays the DSU entries for tomorrow'
      long_desc <<-LONG_DESC
        Displays the DSU entries for tomorrow. This command has no options.
      LONG_DESC
      def tomorrow
        time = Time.now
        times = sorted_dsu_times_for(times: [time.tomorrow, time])
        view_list_for(times: times)
      end

      desc 'yesterday, y',
        'Displays the DSU entries for yesterday'
      long_desc <<-LONG_DESC
        Displays the DSU entries for yesterday. This command has no options.
      LONG_DESC
      def yesterday
        time = Time.now
        times = sorted_dsu_times_for(times: [time.yesterday, time.yesterday.yesterday])
        view_list_for(times: times)
      end

      desc 'date, d DATE|MNEUMONIC',
        'Displays the DSU entries for the DATE or MNEUMONIC provided'
      long_desc <<-LONG_DESC
        Displays the DSU entries for the DATE or MNEUMONIC provided.

        \x5
        #{date_option_description}

        \x5
        #{mneumonic_option_description}
      LONG_DESC
      def date(param)
        time = if time_mneumonic?(param)
          time_from_mneumonic(command_option: param)
        else
          Time.parse(param)
        end
        times = sorted_dsu_times_for(times: [time, time.yesterday])
        view_list_for(times: times)
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

        OPTIONS
        \x5
        -a|--include-all true|false: If true, all DSU dates within the specified range will be displayed. If false, DSU dates between the first and last DSU dates that have NO entries will NOT be displayed.. The default is taken from the dsu configuration setting :include_all, see `dsu config info`.

        \x5
        -f|--from DATE|MNEMONIC: The DATE or MNEUMONIC that represents the start of the range of DSU dates to display. If a relative mneumonic is used (+/-n, e.g +1, -1, etc.), the date calculated will be relative to the current date (e.g. `<MNEUMONIC>.to_i.days.from_now(Time.now)`).

        \x5
        -t|--to DATE|MNEMONIC: The DATE or MNEUMONIC that represents the end of the range of DSU dates to display. If a relative mneumonic is used (+/-n, e.g +1, -1, etc.), the date calculated will be relative to the date that resulting from the `--from` option date calculation.

        \x5
        #{date_option_description}

        \x5
        #{mneumonic_option_description}

        \x5
        EXAMPLES

        \x5
        NOTE: All examples are subject to the `--include-all` option.

        \x5
        # The below will display the DSU entries for the range of dates from 1/1 to 1/4.
        \x5`dsu list dates --from 1/1 --to +3`

        \x5
        # will display the DSU entries for the range of dates from 1/2 to 1/5.
        \x5`dsu list dates --from 1/5 --to -3`

        \x5
        # (assuming "today" is 1/10) will display the DSU entries for the last week 1/10 to 1/3.
        \x5`dsu list dates --from today --to -7`

        \x5
        # (assuming "today" is 5/23) will display the DSU entries for the last week 5/16 to 5/22.
        #
        # This example simply illustrates the fact that you can use relative mneumonics for
        # both `--from` and `--to` options; this doesn't mean you should do so...
        #
        # While you can use relative mneumonics for both `--from` and `--to` options,
        # there is always a more intuitive way. The below example basically lists one week
        # of DSU entries back 1 week from yesterday's date:
        \x5`dsu list dates --from -7 --to +6`

        \x5
        # This can MUCH easily be accomplished by simply using the `yesterday` mneumonic:
        # (assuming "today" is 5/23) will display the DSU entries back 1 week from yesterday's date 5/16 to 5/22.
        \x5`dsu list dates --from yesterday --to -6`
      LONG_DESC
      # -f, --from FROM [DATE|MNEMONIC] (e.g. -f, --from 1/1[/yyy]|n|t|y|today|tomorrow|yesterday)
      option :from, type: :string, aliases: '-f', banner: 'DATE|MNEMONIC'
      # -t, --to TO [DATE|MNEMONIC] (e.g. -t, --to 1/1[/yyy]|n|t|y|today|tomorrow|yesterday)
      option :to, type: :string, aliases: '-t', banner: 'DATE|MNEMONIC'

      # Include dates that have no DSU entries.
      option :include_all, type: :boolean, aliases: '-a'
      def dates
        options = configuration.merge(self.options).with_indifferent_access
        times = dsu_times_from!(from_command_option: options[:from], to_command_option: options[:to])
        # Note special sort here, unlike the other commands where rules for
        # displaying DSU entries are applied; this is more of a list command.
        times = times_sort(times: times, entries_display_order: entries_display_order)
        view_entry_groups(times: times, options: options) do |total_entry_groups|
          nothing_to_display_banner_for(times) if total_entry_groups.zero?
        end
      rescue ArgumentError => e
        say "Error: #{e.message}", ERROR
        exit 1
      end

      private

      def nothing_to_display_banner_for(entry_group_times)
        entry_group_times.sort!
        time_range = "#{formatted_time(time: entry_group_times.first)} " \
                     "through #{formatted_time(time: entry_group_times.last)}"
        say "(nothing to display for #{time_range})", INFO
      end

      # This method will unconditionally display the FIRST and LAST entry groups
      # associated with the times provided by the <times> argument. All other
      # entry groups will be conditionally displayed based on the :include_all
      # value in the <options> argument.
      def view_list_for(times:)
        options = configuration.merge(self.options)
        times_first_and_last = [times.first, times.last]
        times.each do |time|
          view_options = options.dup
          view_options.include_all = true if times_first_and_last.include?(time)
          view_entry_group(time: time, options: view_options) do
            puts
          end
        end
      end
    end
  end
end
