# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/object/blank'
require 'bundler'
require 'thor'
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
  end
end
