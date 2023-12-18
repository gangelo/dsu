# frozen_string_literal: true

require_relative '../services/entry_group/counter_service'
require_relative '../support/command_options/dsu_times'
require_relative '../support/command_options/time_mnemonic'
require_relative '../support/time_formatable'
require_relative '../views/entry_group/shared/no_entries_to_display'
require_relative '../views/shared/error'
require_relative 'base_subcommand'

module Dsu
  module Subcommands
    class List < BaseSubcommand
      include Support::CommandOptions::TimeMnemonic
      include Support::TimeFormatable

      map %w[d] => :date
      map %w[dd] => :dates
      map %w[n] => :today
      map %w[t] => :tomorrow
      map %w[y] => :yesterday

      desc I18n.t('subcommands.list.today.desc'), I18n.t('subcommands.list.today.usage')
      long_desc I18n.t('subcommands.list.today.long_desc')
      def today
        time = Time.now
        times = sorted_dsu_times_for(times: [time.yesterday, time])
        view_list_for(times: times, options: options)
      end

      desc I18n.t('subcommands.list.tomorrow.desc'), I18n.t('subcommands.list.tomorrow.usage')
      long_desc I18n.t('subcommands.list.tomorrow.long_desc')
      def tomorrow
        time = Time.now
        times = sorted_dsu_times_for(times: [time, time.tomorrow])
        view_list_for(times: times, options: options)
      end

      desc I18n.t('subcommands.list.yesterday.desc'), I18n.t('subcommands.list.yesterday.usage')
      long_desc I18n.t('subcommands.list.yesterday.long_desc')
      def yesterday
        time = Time.now
        times = sorted_dsu_times_for(times: [time.yesterday, time.yesterday.yesterday])
        view_list_for(times: times, options: options)
      end

      desc I18n.t('subcommands.list.date.desc'), I18n.t('subcommands.list.date.usage')
      long_desc I18n.t('subcommands.list.date.long_desc',
        date_option_description: date_option_description,
        mnemonic_option_description: mnemonic_option_description)
      def date(date_or_mnemonic)
        time = if time_mnemonic?(date_or_mnemonic)
          time_from_mnemonic(command_option: date_or_mnemonic)
        else
          Time.parse(date_or_mnemonic)
        end
        times = sorted_dsu_times_for(times: [time, time.yesterday])
        view_list_for(times: times, options: options)
      rescue ArgumentError => e
        Views::Shared::Error.new(messages: e.message).render
      end

      desc I18n.t('subcommands.list.dates.desc'), I18n.t('subcommands.list.dates.usage')
      long_desc I18n.t('subcommands.list.dates.long_desc',
        date_option_description: date_option_description,
        mnemonic_option_description: mnemonic_option_description)
      option :from, type: :string, required: true, aliases: '-f', banner: 'DATE|MNEMONIC'
      option :to, type: :string, required: true, aliases: '-t', banner: 'DATE|MNEMONIC'
      option :include_all, default: nil, type: :boolean, aliases: '-a',
        desc: I18n.t('options.include_all')
      def dates
        options = configuration.to_h.merge(self.options).with_indifferent_access
        times, errors = Support::CommandOptions::DsuTimes.dsu_times_for(from_option: options[:from], to_option: options[:to]) # rubocop:disable Layout/LineLength
        if errors.any?
          Views::Shared::Error.new(messages: errors).render
          return
        end

        # NOTE: special sort here, unlike the other commands where rules for
        # displaying DSU entries are applied; this is more of a list command.
        times = times_sort(times: times, entries_display_order: options[:entries_display_order])
        view_entry_groups(times: times, options: options) do |_total_entry_groups, _total_entry_groups_not_shown|
          if Services::EntryGroup::CounterService.new(times: times).call.zero?
            Views::EntryGroup::Shared::NoEntriesToDisplay.new(times: times, options: options).render
          end
        end
      rescue ArgumentError => e
        Views::Shared::Error.new(messages: e.message).render
      end
    end
  end
end
