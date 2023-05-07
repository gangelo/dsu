# frozen_string_literal: true

require 'time'
require_relative 'base_cli'
require_relative 'subcommands/config'
require_relative 'subcommands/list'

module Dsu
  #
  # The `dsu` command.
  #
  class CLI < BaseCLI
    map %w[add -a] => :add
    map %w[config -c] => :config
    map %w[list -l] => :list
    map %w[version -v] => :version

    desc 'add, -a [OPTIONS] DESCRIPTION',
      'Will add a DSU entry having DESCRIPTION to the date associated with the given OPTION.'
    long_desc <<-LONG_DESC
      NAME
      \x5
      `DSU add, -a [OPTIONS] DESCRIPTION` -- will add a DSU entry having DESCRIPTION to the date associated with the given OPTION.

      SYNOPSIS
      \x5
      `dsu add, -a [-d DATE|-n|-t|-y] DESCRIPTION`

      OPTIONS:
      \x5
      -d DATE: Adds a DSU entry having DESCRIPTION to the DATE.

      \x5 #{date_option_description}

      \x5 -n: Adds a DSU entry having DESCRIPTION to today's date (`Time.now`).

      \x5 -t: Adds a DSU entry having DESCRIPTION to tomorrow's date (`Time.new.tomorrow`).

      \x5 -y: Adds a DSU entry having DESCRIPTION to yesterday's date (`Time.new.yesterday`).

    LONG_DESC
    option :date, type: :string, aliases: '-d'
    option :tomorrow, type: :boolean, aliases: '-t'
    option :yesterday, type: :boolean, aliases: '-y'
    option :today, type: :boolean, aliases: '-n', default: true

    def add(description)
      times = if options[:date].present?
        time = Time.parse(options[:date])
        [time, time.yesterday]
      else
        time = Time.now
        if options[:tomorrow].present?
          [time.tomorrow, time.tomorrow.yesterday]
        elsif options[:yesterday].present?
          [time.yesterday, time.yesterday.yesterday]
        elsif options[:today].present?
          [time, time.yesterday]
        end
      end
      entry = Models::Entry.new(description: description)
      # NOTE: We need to add the Entry to the date that is the furthest in the future
      # (time.max) because this is the DSU entry that the user specified.
      CommandServices::AddEntryService.new(entry: entry, time: times.max).call
      sorted_dsu_times_for(times: times).each do |t|
        view_entry_group(time: t)
        puts
      end
    end

    desc 'list, -l SUBCOMMAND',
      'Displays DSU entries for the given SUBCOMMAND.'
    subcommand :list, Subcommands::List

    # TODO: Implement this.
    # desc 'interactive', 'Opens a DSU interactive session'
    # long_desc ''
    # option :next_day, type: :boolean, aliases: '-n'
    # option :previous_day, type: :boolean, aliases: '-p'
    # option :today, type: :boolean, aliases: '-t'

    # # https://stackoverflow.com/questions/4604905/interactive-prompt-with-thor
    # def interactive
    #   exit_commands = %w[x q exit quit]
    #   display_interactive_help
    #   loop do
    #     command = ask('dsu > ')
    #     display_interactive_help if command == 'h'
    #     break if exit_commands.include? command
    #   end
    #   say 'Done.'
    # end

    desc 'config, -c SUBCOMMAND',
      'Manage configuration file for this gem'
    subcommand :config, Subcommands::Config

    desc 'version, -v',
      'Displays this gem version'
    def version
      say VERSION
    end

    private

    def display_interactive_help
      say 'Interactive Mode Commands:'
      say '---'
      say '[h]: show this help screen'
      say '[t]: next day'
      say '[y]: previous day'
      say '[n]: today'
      say '[x|q|exit|quit]: Exit interactive mode'
    end
  end
end
