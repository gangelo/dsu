# frozen_string_literal: true

require_relative '../support/command_options/dsu_times'
require_relative '../support/command_options/time_mneumonic'
require_relative '../support/time_formatable'
require_relative '../views/entry_group/shared/no_entries_to_display'
require_relative '../views/shared/generic_errors'
require_relative 'base_subcommand'

module Dsu
  module Subcommands
    class List < BaseSubcommand
      include Support::CommandOptions::TimeMneumonic
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
      option :include_all, type: :boolean, aliases: '-a', desc: 'Include dates that have no DSU entries'
      def today
        time = Time.now
        times = sorted_dsu_times_for(times: [time.yesterday, time])
        view_list_for(times: times, options: options)
      end

      desc 'tomorrow, t',
        'Displays the DSU entries for tomorrow'
      long_desc <<-LONG_DESC
        Displays the DSU entries for tomorrow. This command has no options.
      LONG_DESC
      option :include_all, type: :boolean, aliases: '-a', desc: 'Include dates that have no DSU entries'
      def tomorrow
        time = Time.now
        times = sorted_dsu_times_for(times: [time, time.tomorrow])
        view_list_for(times: times, options: options)
      end

      desc 'yesterday, y',
        'Displays the DSU entries for yesterday'
      long_desc <<-LONG_DESC
        Displays the DSU entries for yesterday. This command has no options.
      LONG_DESC
      option :include_all, type: :boolean, aliases: '-a', desc: 'Include dates that have no DSU entries'
      def yesterday
        time = Time.now
        times = sorted_dsu_times_for(times: [time.yesterday, time.yesterday.yesterday])
        view_list_for(times: times, options: options)
      end

      desc 'date, d DATE|MNEUMONIC',
        'Displays the DSU entries for the DATE or MNEUMONIC provided'
      long_desc <<-LONG_DESC
        Displays the DSU entries for the DATE or MNEUMONIC provided.

        #{date_option_description}

        #{mneumonic_option_description}
      LONG_DESC
      option :include_all, type: :boolean, aliases: '-a', desc: 'Include dates that have no DSU entries'
      def date(date_or_mneumonic)
        time = if time_mneumonic?(date_or_mneumonic)
          time_from_mneumonic(command_option: date_or_mneumonic)
        else
          Time.parse(date_or_mneumonic)
        end
        times = sorted_dsu_times_for(times: [time, time.yesterday])
        view_list_for(times: times, options: options)
      rescue ArgumentError => e
        Views::Shared::GenericErrors.new(errors: e.message).render
      end

      desc 'dates|dd OPTIONS',
        'Displays the DSU entries for the OPTIONS provided'
      long_desc <<~LONG_DESC
        NAME

        $ dsu dates|dd OPTIONS -- will display the DSU entries for the OPTIONS provided.

        SYNOPSIS

        $ dsu dates|dd OPTIONS

        OPTIONS

        -a|--include-all true|false: If true, all DSU dates within the specified range will be displayed. If false, DSU dates between the first and last DSU dates that have NO entries will NOT be displayed.. The default is taken from the dsu configuration setting :include_all, see `dsu config info`.

        -f|--from DATE|MNEMONIC: The DATE or MNEUMONIC that represents the start of the range of DSU dates to display. If a relative mneumonic is used (+/-n, e.g +1, -1, etc.), the date calculated will be relative to the current date (e.g. `<MNEUMONIC>.to_i.days.from_now(Time.now)`).

        -t|--to DATE|MNEMONIC: The DATE or MNEUMONIC that represents the end of the range of DSU dates to display. If a relative mneumonic is used (+/-n, e.g +1, -1, etc.), the date calculated will be relative to the date that resulting from the `--from` option date calculation.

        #{date_option_description}

        #{mneumonic_option_description}

        EXAMPLES

        NOTE: All examples are subject to the `--include-all` option.

        The below will display the DSU entries for the range of dates from 1/1 to 1/4:

        $ dsu list dates --from 1/1 --to +3

        This will display the DSU entries for the range of dates from 1/2 to 1/5:

        $ dsu list dates --from 1/5 --to -3

        This (assuming "today" is 1/10) will display the DSU entries for the last week 1/10 to 1/3:

        $ dsu list dates --from today --to -7

        This (assuming "today" is 5/23) will display the DSU entries for the last week 5/16 to 5/22.
        This example simply illustrates the fact that you can use relative mneumonics for
        both `--from` and `--to` options; this doesn't mean you should do so...

        While you can use relative mneumonics for both `--from` and `--to` options,
        there is always a more intuitive way. The below example basically lists one week
        of DSU entries back 1 week from yesterday's date:

        $ dsu list dates --from -7 --to +6

        The above can be accomplished MUCH easier by simply using the `yesterday` mneumonic...

        This (assuming "today" is 5/23) will display the DSU entries back 1 week from yesterday's date 5/16 to 5/22:

        $ dsu list dates --from yesterday --to -6
      LONG_DESC
      # -f, --from FROM [DATE|MNEMONIC] (e.g. -f, --from 1/1[/yyy]|n|t|y|today|tomorrow|yesterday)
      option :from, type: :string, required: true, aliases: '-f', banner: 'DATE|MNEMONIC'
      # -t, --to TO [DATE|MNEMONIC] (e.g. -t, --to 1/1[/yyy]|n|t|y|today|tomorrow|yesterday)
      option :to, type: :string, required: true, aliases: '-t', banner: 'DATE|MNEMONIC'
      # Include dates that have no DSU entries.
      option :include_all, type: :boolean, aliases: '-a', desc: 'Include dates that have no DSU entries'
      def dates
        options = configuration.to_h.merge(self.options).with_indifferent_access
        times, errors = Support::CommandOptions::DsuTimes.dsu_times_for(from_option: options[:from], to_option: options[:to]) # rubocop:disable Layout/LineLength
        if errors.any?
          Views::Shared::GenericErrors.new(errors: errors).render
          return
        end

        # NOTE: special sort here, unlike the other commands where rules for
        # displaying DSU entries are applied; this is more of a list command.
        times = times_sort(times: times, entries_display_order: options[:entries_display_order])
        view_entry_groups(times: times, options: options) do |total_entry_groups, _total_entry_groups_not_shown|
          # nothing_to_display_banner_for(times) if total_entry_groups.zero?
          Views::EntryGroup::Shared::NoEntriesToDisplay.new(times: times, options: options) if total_entry_groups.zero?
        end
      rescue ArgumentError => e
        Views::Shared::GenericErrors.new(errors: e.message).render
      end
    end
  end
end
