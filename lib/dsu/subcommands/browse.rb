# frozen_string_literal: true

require 'io/console'

require_relative '../services/entry_group/browse_service'
require_relative '../services/entry_group/counter_service'
require_relative '../services/stdout_redirector_service'
require_relative '../support/command_options/dsu_times'
require_relative '../support/command_options/time_mnemonic'
require_relative '../support/time_formatable'
require_relative '../views/entry_group/shared/no_entries_to_display'
require_relative '../views/shared/error'
require_relative 'base_subcommand'

module Dsu
  module Subcommands
    class Browse < BaseSubcommand
      include Support::CommandOptions::TimeMnemonic
      include Support::TimeFormatable

      # TODO: I18n.
      # map %w[d] => :date
      map %w[w] => :week
      map %w[m] => :month
      map %w[y] => :year

      class_option :include_all, default: nil, type: :boolean, aliases: '-a',
        desc: I18n.t('options.include_all')

      # desc I18n.t('subcommands.browse.date.desc'), I18n.t('subcommands.browse.date.usage')
      # long_desc I18n.t('subcommands.browse.date.long_desc',
      #   date_option_description: date_option_description,
      #   mnemonic_option_description: mnemonic_option_description)
      # def date(date_or_mnemonic)
      #   time = if time_mnemonic?(date_or_mnemonic)
      #     time_from_mnemonic(command_option: date_or_mnemonic)
      #   else
      #     Time.parse(date_or_mnemonic)
      #   end
      #   show_entry_group time: time, options: options
      # rescue ArgumentError => e
      #   Views::Shared::Error.new(messages: e.message).render
      # end

      desc I18n.t('subcommands.browse.week.desc'), I18n.t('subcommands.browse.week.usage')
      long_desc I18n.t('subcommands.browse.week.long_desc')
      def week
        show_entry_group time: Time.now, options: options.merge({ week: true })
      end

      desc I18n.t('subcommands.browse.month.desc'), I18n.t('subcommands.browse.month.usage')
      long_desc I18n.t('subcommands.browse.month.long_desc')
      def month
        show_entry_group time: Time.now, options: options.merge({ month: true })
      end

      desc I18n.t('subcommands.browse.year.desc'), I18n.t('subcommands.browse.year.usage')
      long_desc I18n.t('subcommands.browse.year.long_desc')
      def year
        show_entry_group time: Time.now, options: options.merge({ year: true })
      end

      private

      def show_entry_group(time:, options:)
        times = browse_service(time: time, options: options).call.filter_map do |entry_group_data|
          Time.parse entry_group_data.keys[0]
        end

        # NOTE: special sort here, unlike the other commands where rules for
        # displaying DSU entries are applied; this is more of a list command.
        times = times_sort(times: times, entries_display_order: options[:entries_display_order])
        output = Services::StdoutRedirectorService.call do
          self.class.display_dsu_header
          view_entry_groups(times: times, options: options) do |_total_entry_groups, _total_entry_groups_not_shown|
            if Services::EntryGroup::CounterService.new(times: times).call.zero?
              Views::EntryGroup::Shared::NoEntriesToDisplay.new(times: times, options: options).render
            end
          end
          self.class.display_dsu_footer
        end
        output_with_pager output
      end

      def browse_service(time:, options: {})
        Services::EntryGroup::BrowseService.new(time: time, options: options)
      end

      def output_with_pager(string)
        pager_command = if RUBY_PLATFORM.match?(/win32|windows/i)
          'more' # Windows command
        else
          'less' # Unix-like command
        end

        IO.popen(pager_command, 'w') do |pipe|
          pipe.puts string
          pipe.close_write
        end
      rescue Errno::ENOENT
        message = "Operating system pager command (#{pager_command}) not found. Falling back to direct output."
        Views::Shared::Error.new(messages: message).render
        puts string
      end
    end
  end
end