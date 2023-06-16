# frozen_string_literal: true

require 'fileutils'
require 'time'
require_relative 'base_cli'
require_relative 'subcommands/config'
require_relative 'subcommands/edit'
require_relative 'subcommands/generate'
require_relative 'subcommands/list'
require_relative 'subcommands/theme'

module Dsu
  # The `dsu` command.
  class CLI < BaseCLI
    map %w[a -a] => :add
    map %w[c -c] => :config
    map %w[e -e] => :edit
    map %w[g -g] => :generate
    map %w[l -l] => :list
    map %w[t -t] => :theme
    map %w[v -v] => :version

    desc 'add, -a [OPTIONS] DESCRIPTION',
      'Adds a DSU entry having DESCRIPTION to the date associated with the given OPTION'
    long_desc <<-LONG_DESC
      NAME
      \x5
      `dsu add, -a [OPTIONS] DESCRIPTION` -- will add a DSU entry having DESCRIPTION to the date associated with the given OPTION.

      SYNOPSIS
      \x5
      `dsu add, -a [-d DATE|-n|-t|-y] DESCRIPTION`

      OPTIONS:
      \x5
      -d DATE: Adds a DSU entry having DESCRIPTION to the DATE.

      \x5
      #{date_option_description}

      \x5
      -n: Adds a DSU entry having DESCRIPTION to today's date (`Time.now`).

      \x5
      -t: Adds a DSU entry having DESCRIPTION to tomorrow's date (`Time.new.tomorrow`).

      \x5
      -y: Adds a DSU entry having DESCRIPTION to yesterday's date (`Time.new.yesterday`).

      DESCRIPTION:
      \x5
      Must be be between 2 and 256 characters (inclusive) in length.
    LONG_DESC
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

    desc 'list, -l SUBCOMMAND',
      'Displays DSU entries for the given SUBCOMMAND'
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

    if ENV['DEV_ENV']
      desc 'generate, -g SUBCOMMAND',
        'Runs the DSU generator for the given SUBCOMMAND'
      subcommand :generate, Subcommands::Generate
    end

    desc 'version, -v',
      'Displays this gem version'
    def version
      puts VERSION
    end
  end
end
