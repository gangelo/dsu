# frozen_string_literal: true

require 'bundler'
require 'thor'
require_relative 'command_services/add_entry_service'
require_relative 'services/entry_group_hydrator_service'
require_relative 'services/entry_group_displayer_service'
require_relative 'services/entry_group_reader_service'
require_relative 'subcommands/config'
require_relative 'version'

module Dsu
  #
  # The `dsu` command.
  #
  class CLI < ::Thor
    class_option :debug, type: :boolean, default: false

    map %w[--version -v] => :version
    # map %w[--interactive -i] => :interactive

    default_command :help

    class << self
      def exit_on_failure?
        false
      end
    end

    desc 'add [OPTIONS] DESCRIPTION [LONG-DESCRIPTION]',
      'Adds a dsu entry for the date associated with the given option.'
    long_desc <<-LONG_DESC
      TBD
    LONG_DESC
    option :date, type: :string, aliases: '-d'
    option :next_day, type: :boolean, aliases: '-n'
    option :previous_day, type: :boolean, aliases: '-p'
    option :today, type: :boolean, aliases: '-t', default: true

    def add(description, long_description = nil)
      entry = Dsu::Support::Entry.new(description: description, long_description: long_description)
      time = if options[:date].present?
        Time.parse(options[:date])
      elsif options[:next_day].present?
        1.day.from_now
      elsif options[:previous_day].present?
        1.day.ago
      elsif options[:today].present?
        Time.now
      else
        raise 'No date option specified.'
      end
      #require 'pry-byebug'
      #binding.pry
      display_entry_group(time: 1.day.ago(time))
      Dsu::CommandServices::AddEntryService.new(entry: entry, time: time).call
      display_entry_group(time: time)
    end

    desc 'interactive', 'Opens a dsu interactive session'
    long_desc ''
    option :next_day, type: :boolean, aliases: '-n'
    option :previous_day, type: :boolean, aliases: '-p'
    option :today, type: :boolean, aliases: '-t'

    # https://stackoverflow.com/questions/4604905/interactive-prompt-with-thor
    def interactive
      exit_commands = %w[x q exit quit]
      display_interactive_help
      loop do
        command = ask('dsu > ')
        display_interactive_help if command == 'h'
        break if exit_commands.include? command
      end
      say 'Done.'
    end

    desc 'config SUBCOMMAND', 'Manage configuration file for this gem'
    subcommand :config, Dsu::Subcommands::Config

    desc '--version, -v', 'Displays this gem version'
    def version
      say Dsu::VERSION
    end

    private

    def display_interactive_help
      say 'Interactive Mode Commands:'
      say '---'
      say '[h]: show this help screen'
      say '[n]: next day'
      say '[p]: previous day'
      say '[t]: today'
      say '[x|q|exit|quit]: Exit interactive mode'
    end

    def display_entry_group(time:)
      entry_group_json = Dsu::Services::EntryGroupReaderService.new(time: time).call
      entry_group = Dsu::Services::EntryGroupHydratorService.new(entry_group_json: entry_group_json).call
      Dsu::Services::EntryGroupDisplayerService.new(entry_group: entry_group).call
    end
  end
end
