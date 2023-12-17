# frozen_string_literal: true

require_relative '../services/entry_group/counter_service'
require_relative '../services/entry_group/deleter_service'
require_relative '../support/command_options/dsu_times'
require_relative '../support/command_options/time_mnemonic'
require_relative '../support/time_formatable'
require_relative '../views/entry_group/shared/no_entries_to_display'
require_relative '../views/shared/error'
require_relative 'base_subcommand'

module Dsu
  module Subcommands
    class Delete < BaseSubcommand
      include Support::CommandOptions::TimeMnemonic
      include Support::TimeFormatable

      map %w[d] => :date
      map %w[dd] => :dates
      map %w[n] => :today
      map %w[t] => :tomorrow
      map %w[y] => :yesterday

      desc I18n.t('subcommands.delete.today.desc'), I18n.t('subcommands.delete.today.usage')
      long_desc I18n.t('subcommands.delete.today.long_desc')
      option :prompts, type: :hash, default: {}, hide: true, aliases: '-p'
      def today
        delete_entry_groups_if times: [Time.now], options: options
      end

      desc I18n.t('subcommands.delete.tomorrow.desc'), I18n.t('subcommands.delete.tomorrow.usage')
      long_desc I18n.t('subcommands.delete.tomorrow.long_desc')
      option :prompts, type: :hash, default: {}, hide: true, aliases: '-p'
      def tomorrow
        delete_entry_groups_if times: [Time.now.tomorrow], options: options
      end

      desc I18n.t('subcommands.delete.yesterday.desc'), I18n.t('subcommands.delete.yesterday.usage')
      long_desc I18n.t('subcommands.delete.yesterday.long_desc')
      option :prompts, type: :hash, default: {}, hide: true, aliases: '-p'
      def yesterday
        delete_entry_groups_if times: [Time.now.yesterday], options: options
      end

      desc I18n.t('subcommands.delete.date.desc'), I18n.t('subcommands.delete.date.usage')
      long_desc I18n.t('subcommands.delete.date.long_desc',
        date_option_description: date_option_description,
        mnemonic_option_description: mnemonic_option_description)
      option :prompts, type: :hash, default: {}, hide: true, aliases: '-p'
      def date(date_or_mnemonic)
        time = if time_mnemonic?(date_or_mnemonic)
          time_from_mnemonic(command_option: date_or_mnemonic)
        else
          Time.parse(date_or_mnemonic)
        end
        delete_entry_groups_if times: [time], options: options
      rescue ArgumentError => e
        Views::Shared::Error.new(messages: e.message).render
      end

      desc I18n.t('subcommands.delete.dates.desc'), I18n.t('subcommands.delete.dates.usage')
      long_desc I18n.t('subcommands.delete.dates.long_desc',
        date_option_description: date_option_description,
        mnemonic_option_description: mnemonic_option_description)
      option :from, type: :string, required: true, aliases: '-f', banner: 'DATE|MNEMONIC'
      option :to, type: :string, required: true, aliases: '-t', banner: 'DATE|MNEMONIC'
      option :prompts, type: :hash, default: {}, hide: true, aliases: '-p'
      def dates
        options = configuration.to_h.merge(self.options).with_indifferent_access
        times, errors = Support::CommandOptions::DsuTimes.dsu_times_for(from_option: options[:from], to_option: options[:to]) # rubocop:disable Layout/LineLength
        if errors.any?
          Views::Shared::Error.new(messages: errors).render
          return
        end

        times = times_sort(times: times, entries_display_order: options[:entries_display_order])
        delete_entry_groups_if times: times, options: options
      rescue ArgumentError => e
        Views::Shared::Error.new(messages: e.message).render
      end

      private

      def delete_entry_groups_if(times:, options:)
        prompt_string = I18n.t('subcommands.delete.prompts.are_you_sure',
          dates: yyyy_mm_dd_or_through_for(times: times), count: total_entry_groups_for(times: times))
        prompt = color_theme.prompt_with_options(prompt: prompt_string, options: %w[y N])
        if yes?(prompt, options: options)
          deleted_count = delete_entry_groups_for(times: times)
          message = I18n.t('subcommands.delete.messages.deleted', count: deleted_count)
          Views::Shared::Success.new(messages: message).render
        else
          message = I18n.t('subcommands.delete.messages.canceled')
          Views::Shared::Info.new(messages: message).render
        end
      end

      def delete_entry_groups_for(times:)
        Services::EntryGroup::DeleterService.new(times: times).call
      end

      def total_entry_groups_for(times:)
        Services::EntryGroup::CounterService.new(times: times).call
      end
    end
  end
end
