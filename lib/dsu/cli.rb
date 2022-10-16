# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/object/blank'
require 'bundler'
require 'thor'
require_relative 'version'

module Dsu
  #
  # The `dsu` command.
  #
  class CLI < ::Thor
    class_option :debug, type: :boolean, default: false

    map %w[--version -v] => :version
    #    map %w[--interactive -i] => :interactive

    default_command :help

    desc 'interactive', 'Opens a dsu interactive session.'
    long_desc ''
    method_option :interactive, type: :boolean, aliases: '-i'

    # https://stackoverflow.com/questions/4604905/interactive-prompt-with-thor
    def interactive
      exit_commands = %w[x q exit quit]
      display_interactive_help
      loop do
        command = ask('dsu > ')
        break if exit_commands.include? command
      end
      say 'Done.'
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
