# frozen_string_literal: true

require 'bundler'
require 'thor'
require_relative 'command_services/add_entry_service'
require_relative 'models/entry_group'
require_relative 'services/configuration_loader_service'
require_relative 'services/entry_group_hydrator_service'
require_relative 'services/entry_group_reader_service'
require_relative 'support/colorable'
require_relative 'subcommands/config'
require_relative 'version'
require_relative 'views/entry_group/show'

module Dsu
  #
  # The `dsu` command.
  #
  class CLI < ::Thor
    include Support::Colorable

    class_option :debug, type: :boolean, default: false

    map %w[add -a] => :add
    map %w[config -c] => :config
    map %w[date -d] => :date
    map %w[today -n] => :today
    map %w[tomorrow -t] => :tomorrow
    map %w[version -v] => :version
    map %w[yesterday -y] => :yesterday

    default_command :help

    class << self
      def exit_on_failure?
        false
      end

      def date_option_description
        <<-DATE_OPTION_DESC
          Where DATE may be any date string that can be parsed using `Time.parse`. Consequently, you may use also use '/' as date separators, as well as omit thee year if the date you want to display is the current year (e.g. <month>/<day>, or 1/31). For example: `require 'time'; Time.parse('2023-01-02'); Time.parse('1/2') # etc.`
        DATE_OPTION_DESC
      end
    end

    def initialize(*args)
      super

      @configuration = Services::ConfigurationLoaderService.new.call
    end

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
      time = if options[:date].present?
        Time.parse(options[:date])
      elsif options[:tomorrow].present?
        1.day.from_now
      elsif options[:yesterday].present?
        1.day.ago
      elsif options[:today].present?
        Time.now
      end
      entry = Models::Entry.new(description: description)
      CommandServices::AddEntryService.new(entry: entry, time: time).call
      sort_times(times: [1.day.ago(time), time]).each do |time| # rubocop:disable Lint/ShadowingOuterLocalVariable
        display_entry_group(time: time)
        puts
      end
    end

    desc 'today, -n',
      'Displays the DSU entries for today.'
    long_desc <<-LONG_DESC
      Displays the DSU entries for today. This command has no options.
    LONG_DESC
    def today
      time = Time.now
      sort_times(times: [1.day.ago(time), time]).each do |time| # rubocop:disable Lint/ShadowingOuterLocalVariable
        display_entry_group(time: time)
        puts
      end
    end

    desc 'tomorrow, -t',
      'Displays the DSU entries for tomorrow.'
    long_desc <<-LONG_DESC
      Displays the DSU entries for tomorrow. This command has no options.
    LONG_DESC
    def tomorrow
      time = Time.now
      sort_times(times: [1.day.from_now(time), time]).each do |time| # rubocop:disable Lint/ShadowingOuterLocalVariable
        display_entry_group(time: time)
        puts
      end
    end

    desc 'yesterday, -y',
      'Displays the DSU entries for yesterday.'
    long_desc <<-LONG_DESC
      Displays the DSU entries for yesterday. This command has no options.
    LONG_DESC
    def yesterday
      time = Time.now
      sort_times(times: [1.day.ago(time), 2.days.ago(time)]).each do |time| # rubocop:disable Lint/ShadowingOuterLocalVariable
        display_entry_group(time: time)
        puts
      end
    end

    desc 'date, -d DATE',
      'Displays the DSU entries for DATE.'
    long_desc <<-LONG_DESC
      Displays the DSU entries for DATE.

      For example: `require 'time'; Time.parse('2023-01-02'); Time.parse('1/2') # etc.`

      Basically, where DATE is any date string that can be parsed using `Time.parse`; consequently, you may use also use '/' as date separators, as well as omit thee year if the date you want to display is the current year (e.g. <month>/<day>, or 1/31).

      This command has no options.
    LONG_DESC
    def date(date)
      time = Time.parse(date)
      sort_times(times: [1.day.ago(time), time]).each do |time| # rubocop:disable Lint/ShadowingOuterLocalVariable
        display_entry_group(time: time)
        puts
      end
    rescue ArgumentError => e
      say "Error: #{e.message}", ERROR
      exit 1
    end

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

    attr_reader :configuration

    def display_interactive_help
      say 'Interactive Mode Commands:'
      say '---'
      say '[h]: show this help screen'
      say '[t]: next day'
      say '[y]: previous day'
      say '[n]: today'
      say '[x|q|exit|quit]: Exit interactive mode'
    end

    def display_entry_group(time:)
      entry_group = if Models::EntryGroup.exists?(time: time)
        entry_group_json = Services::EntryGroupReaderService.new(time: time).call
        Services::EntryGroupHydratorService.new(entry_group_json: entry_group_json).call
      else
        Models::EntryGroup.new(time: time)
      end
      Views::EntryGroup::Show.new(entry_group: entry_group).display
    end

    def sort_times(times:)
      if configuration[:entries_display_order] == 'asc'
        times.sort # sort ascending
      elsif configuration[:entries_display_order] == 'desc'
        times.sort.reverse # sort descending
      end
    end
  end
end
