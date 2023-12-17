# frozen_string_literal: true

require 'fileutils'
require 'time'
require_relative 'base_cli'
require_relative 'subcommands/config'
require_relative 'subcommands/delete'
require_relative 'subcommands/edit'
require_relative 'subcommands/list'
require_relative 'subcommands/theme'

module Dsu
  # The `dsu` command.
  class CLI < BaseCLI
    map I18n.t('commands.add.key_mappings') => :add
    map I18n.t('commands.config.key_mappings') => :config
    map I18n.t('commands.delete.key_mappings') => :delete
    map I18n.t('commands.edit.key_mappings') => :edit
    map I18n.t('commands.help.key_mappings') => :help
    map I18n.t('commands.info.key_mappings') => :info
    map I18n.t('commands.list.key_mappings') => :list
    map I18n.t('commands.theme.key_mappings') => :theme
    map I18n.t('commands.version.key_mappings') => :version

    desc I18n.t('commands.add.desc'), I18n.t('commands.add.usage')
    long_desc I18n.t('commands.add.long_desc', date_option_description: date_option_description)
    option I18n.t('options.date.name'), type: :string, aliases: I18n.t('options.date.aliases')
    option I18n.t('options.tomorrow.name'), type: :boolean, aliases: I18n.t('options.tomorrow.aliases')
    option I18n.t('options.yesterday.name'), type: :boolean, aliases: I18n.t('options.yesterday.aliases')
    option I18n.t('options.today.name'), type: :boolean, default: true, aliases: I18n.t('options.today.aliases')
    def add(description)
      time = if options[I18n.t('options.date.name')].present?
        Time.parse(options[I18n.t('options.date.name')])
      elsif options[I18n.t('options.tomorrow.name')].present?
        Time.now.tomorrow
      elsif options[I18n.t('options.yesterday.name')].present?
        Time.now.yesterday
      elsif options[I18n.t('options.today.name')].present?
        Time.now
      end
      entry = Models::Entry.new(description: description)
      CommandServices::AddEntryService.new(entry: entry, time: time).call
      view_entry_group(time: time)
    end

    desc I18n.t('commands.list.desc'), I18n.t('commands.list.usage')
    subcommand :list, Subcommands::List

    desc I18n.t('commands.config.desc'), I18n.t('commands.config.usage')
    subcommand :config, Subcommands::Config

    desc I18n.t('commands.delete.desc'), I18n.t('commands.delete.usage')
    subcommand :delete, Subcommands::Delete

    desc I18n.t('commands.edit.desc'), I18n.t('commands.edit.usage')
    subcommand :edit, Subcommands::Edit

    desc I18n.t('commands.theme.desc'), I18n.t('commands.theme.usage')
    subcommand :theme, Subcommands::Theme

    desc I18n.t('commands.info.desc'), I18n.t('commands.info.usage')
    def info
      configuration_version = Models::Configuration::VERSION
      entry_group_version = Models::EntryGroup::VERSION
      color_theme_version = Models::ColorTheme::VERSION
      info = I18n.t('commands.info.info',
        dsu_version: dsu_version,
        configuration_version: configuration_version,
        entry_group_version: entry_group_version,
        color_theme_version: color_theme_version,
        config_folder: Support::Fileable.config_path,
        root_folder: Support::Fileable.root_folder,
        entries_folder: Support::Fileable.entries_folder,
        themes_folder: Support::Fileable.themes_folder,
        gem_folder: Support::Fileable.gem_dir,
        temp_folder: Support::Fileable.temp_folder,
        migration_version_folder: Support::Fileable.migration_version_folder,
        migration_file_folder: Support::Fileable.migration_version_path)
      puts apply_theme(info, theme_color: color_theme.body)
    end

    desc I18n.t('commands.version.desc'), I18n.t('commands.version.usage')
    def version
      puts apply_theme(dsu_version, theme_color: color_theme.body)
    end

    private

    def dsu_version
      "v#{VERSION}"
    end
  end
end
