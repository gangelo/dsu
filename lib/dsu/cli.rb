# frozen_string_literal: true

require 'fileutils'
require 'time'
require_relative 'base_cli'
require_relative 'subcommands/config'
require_relative 'subcommands/edit'
require_relative 'subcommands/list'
require_relative 'subcommands/theme'

module Dsu
  # The `dsu` command.
  class CLI < BaseCLI
    map %w[a -a] => :add
    map %w[c -c] => :config
    map %w[e -e] => :edit
    map %w[l -l] => :list
    map %w[t -t] => :theme
    map %w[v -i] => :info
    map %w[v -v] => :version

    desc I18n.t('cli.commands.add.desc'), I18n.t('cli.commands.add.usage')
    long_desc I18n.t('cli.commands.add.long_desc', date_option_description: date_option_description)
    option :date, type: :string, aliases: '-d'
    option :tomorrow, type: :boolean, aliases: '-t'
    option :yesterday, type: :boolean, aliases: '-y'
    option :today, type: :boolean, aliases: '-n', default: true
    def add(description)
      time = if options[:date].present?
        Time.parse(options[:date])
      elsif options[:tomorrow].present?
        Time.now.tomorrow
      elsif options[:yesterday].present?
        Time.now.yesterday
      elsif options[:today].present?
        Time.now
      end
      entry = Models::Entry.new(description: description)
      CommandServices::AddEntryService.new(entry: entry, time: time).call
      view_entry_group(time: time)
    end

    desc I18n.t('cli.commands.list.desc'), I18n.t('cli.commands.list.usage')
    subcommand :list, Subcommands::List

    desc 'config, -c SUBCOMMAND',
      'Manage configuration file for this gem'
    subcommand :config, Subcommands::Config

    desc 'edit, -e SUBCOMMAND',
      'Edit DSU entries for the given SUBCOMMAND'
    subcommand :edit, Subcommands::Edit

    desc 'theme, -t SUBCOMMAND',
      'Manage DSU themes'
    subcommand :theme, Subcommands::Theme

    desc 'info, -i',
      'Displays information about this dsu release'
    def info
      configuration_version = Models::Configuration::VERSION
      entry_group_version = Models::EntryGroup::VERSION
      color_theme_version = Models::ColorTheme::VERSION
      info = <<~INFO
                     Dsu version: #{dsu_version}
           Configuration version: #{configuration_version}
             Entry group version: #{entry_group_version}
             Color theme version: #{color_theme_version}

                     Config path: #{Support::Fileable.config_path}
                     Root folder: #{Support::Fileable.root_folder}
                  Entries folder: #{Support::Fileable.entries_folder}
                   Themes folder: #{Support::Fileable.themes_folder}
                      Gem folder: #{Support::Fileable.gem_dir}
                     Temp folder: #{Support::Fileable.temp_folder}

        Migration version folder: #{Support::Fileable.migration_version_folder}
             Migration file path: #{Support::Fileable.migration_version_path}
      INFO
      puts apply_theme(info, theme_color: color_theme.body)
    end

    desc 'version, -v',
      'Displays the version for this gem'
    def version
      puts apply_theme(dsu_version, theme_color: color_theme.body)
    end

    private

    def dsu_version
      "v#{VERSION}"
    end
  end
end
