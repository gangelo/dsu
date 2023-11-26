# frozen_string_literal: true

require_relative 'base_subcommand'
require_relative '../models/entry_group'
require_relative '../views/entry_group/show'

module Dsu
  module Subcommands
    class Edit < BaseSubcommand
      map %w[d] => :date
      map %w[n] => :today
      map %w[t] => :tomorrow
      map %w[y] => :yesterday

      desc I18n.t('cli.subcommands.edit.date.desc'), I18n.t('cli.subcommands.edit.date.usage')
      long_desc I18n.t('cli.subcommands.edit.date.long_desc', date_option_description: date_option_description)
      def date(date)
        entry_group = Models::EntryGroup.edit(time: Time.parse(date))
        Views::EntryGroup::Show.new(entry_group: entry_group).render
      rescue ArgumentError => e
        puts apply_theme(I18n.t('errors.error', message: e.message), theme_color: color_theme.error)
        exit 1
      end

      desc I18n.t('cli.subcommands.edit.today.desc'), I18n.t('cli.subcommands.edit.today.usage')
      long_desc I18n.t('cli.subcommands.edit.today.long_desc')
      def today
        entry_group = Models::EntryGroup.edit(time: Time.now)
        Views::EntryGroup::Show.new(entry_group: entry_group).render
      end

      desc I18n.t('cli.subcommands.edit.tomorrow.desc'), I18n.t('cli.subcommands.edit.tomorrow.usage')
      long_desc I18n.t('cli.subcommands.edit.tomorrow.long_desc')
      def tomorrow
        entry_group = Models::EntryGroup.edit(time: Time.now.tomorrow)
        Views::EntryGroup::Show.new(entry_group: entry_group).render
      end

      desc I18n.t('cli.subcommands.edit.yesterday.desc'), I18n.t('cli.subcommands.edit.yesterday.usage')
      long_desc I18n.t('cli.subcommands.edit.yesterday.long_desc')
      def yesterday
        entry_group = Models::EntryGroup.edit(time: Time.now.yesterday)
        Views::EntryGroup::Show.new(entry_group: entry_group).render
      end
    end
  end
end
