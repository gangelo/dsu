# frozen_string_literal: true

require 'fileutils'
require 'time'
require_relative 'base_cli'
require_relative 'subcommands/config'
require_relative 'subcommands/edit'
require_relative 'subcommands/generate'
require_relative 'subcommands/list'
require_relative 'subcommands/themes'

module Dsu
  # The `dsu` command.
  class CLI < BaseCLI
    map %w[a -a] => :add
    map %w[c -c] => :config
    map %w[e -e] => :edit
    map %w[g -g] => :generate
    map %w[l -l] => :list
    map %w[t -t] => :themes
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

    # def add(description)
    #   times = if options[:date].present?
    #     time = Time.parse(options[:date])
    #     [time, time.yesterday]
    #   else
    #     time = Time.now
    #     if options[:tomorrow].present?
    #       [time.tomorrow, time.tomorrow.yesterday]
    #     elsif options[:yesterday].present?
    #       [time.yesterday, time.yesterday.yesterday]
    #     elsif options[:today].present?
    #       [time, time.yesterday]
    #     end
    #   end
    #   entry = Models::Entry.new(description: description)
    #   # NOTE: We need to add the Entry to the date that is the furthest in the future
    #   # (time.max) because this is the DSU entry that the user specified.
    #   CommandServices::AddEntryService.new(entry: entry, time: times.max).call
    #   sorted_dsu_times_for(times: times).each do |t|
    #     view_entry_group(time: t)
    #     puts
    #   end
    # end

    desc 'list, -l SUBCOMMAND',
      'Displays DSU entries for the given SUBCOMMAND'
    subcommand :list, Subcommands::List

    desc 'config, -c SUBCOMMAND',
      'Manage configuration file for this gem'
    subcommand :config, Subcommands::Config

    desc 'edit, -e SUBCOMMAND',
      'Edit DSU entries for the given SUBCOMMAND'
    subcommand :edit, Subcommands::Edit

    desc 'themes, -t SUBCOMMAND',
    'Manage DSU themes'
    subcommand :themes, Subcommands::Themes

    if ENV['DEV_ENV'] == 'dev'
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
