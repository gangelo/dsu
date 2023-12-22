# frozen_string_literal: true

require 'io/console'

require_relative '../services/stdout_redirector_service'
require_relative '../support/command_options/dsu_times'
require_relative '../support/command_options/time_mnemonic'
require_relative '../support/entry_group_browsable'
require_relative '../support/time_formatable'
require_relative '../views/entry_group/shared/no_entries_to_display'
require_relative '../views/shared/error'
require_relative 'base_subcommand'

module Dsu
  module Subcommands
    class Browse < BaseSubcommand
      include Support::EntryGroupBrowsable
      include Support::CommandOptions::TimeMnemonic
      include Support::TimeFormatable

      # TODO: I18n.
      map %w[w] => :week
      map %w[m] => :month
      map %w[y] => :year

      class_option :include_all, default: nil, type: :boolean, aliases: '-a',
        desc: I18n.t('options.include_all')

      desc I18n.t('subcommands.browse.week.desc'), I18n.t('subcommands.browse.week.usage')
      long_desc I18n.t('subcommands.browse.week.long_desc')
      def week
        browse_entry_groups time: Time.now, options: options.merge({ browse: :week })
      end

      desc I18n.t('subcommands.browse.month.desc'), I18n.t('subcommands.browse.month.usage')
      long_desc I18n.t('subcommands.browse.month.long_desc')
      def month
        browse_entry_groups time: Time.now, options: options.merge({ browse: :month })
      end

      desc I18n.t('subcommands.browse.year.desc'), I18n.t('subcommands.browse.year.usage')
      long_desc I18n.t('subcommands.browse.year.long_desc')
      def year
        browse_entry_groups time: Time.now, options: options.merge({ browse: :year })
      end
    end
  end
end
