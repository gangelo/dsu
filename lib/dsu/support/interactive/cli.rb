# frozen_string_literal: true

require_relative '../ask'
require_relative '../colors'
require_relative '../say'

module Dsu
  module Interactive
    class Cli
      include Support::Colors
      include Support::Ask
      include Support::Say

      BACK_COMMANDS = %w[b].freeze
      EXIT_COMMANDS = %w[x].freeze
      HELP_COMMANDS = %w[?].freeze
      PROMPT_TOKEN = '>'

      attr_reader :name, :parent, :prompt

      def initialize(name:, parent: nil, **options)
        @name = name
        @parent = parent
        @prompt = options[:prompt]
      end

      # Starts our interactive loop.
      def start
        help
        process_commands
      end

      def process(command:)
        if command.cancelled?
          nil
        elsif help?(command.command)
          help
        elsif back_or_exit?(command.command)
          parent&.help
        else
          unrecognized_command command.command
        end
      end

      # Dispays the full help; header and body.
      def help
        help_header
        help_body
      end

      private

      # This is our interaction loop. Commands that are NOT help or
      # back or exit commands are yielded to the subclass to execute. Help
      # commands simply display help; back (or exit) commands transfer control
      # back to the parent cli (if parent? is true) or exits the current
      # cli (if parent? is false) respectfully.
      def process_commands
        loop do
          command = wrap_command(ask)
          process(command: command)
          next if command.cancelled?
          break if back_or_exit?(command.command)
        end
        say 'Done.', ABORTED unless parent?
      end

      def wrap_command(command)
        Struct.new(:command, :args, :cancelled, keyword_init: true) do
          def cancelled?
            cancelled
          end

          def cancelled!
            self[:cancelled] = true
          end
        end.new(
          command: command.split[0],
          args: command.split[1..],
          cancelled: false
        )
      end

      # This is the full prompt that needs to be displayed that includes
      # all parent prompts, right down to the current prompt.
      def full_prompt
        prompts = full_prompt_build prompts: []
        prompt_token = "#{PROMPT_TOKEN} "
        "#{prompts.join prompt_token}#{prompt_token}"
      end

      def parent?
        !parent.nil?
      end

      def back?(command)
        back_commands.include? command
      end

      def back_commands
        @back_commands ||= BACK_COMMANDS
      end

      def exit?(command)
        exit_commands.include? command
      end

      def exit_commands
        @exit_commands ||= EXIT_COMMANDS
      end

      def back_or_exit?(command)
        (back_commands + exit_commands).include? command
      end

      def help?(command)
        help_commands.include? command
      end

      # Returns what are considered to be commands associated with
      # displaying help.
      def help_commands
        @help_commands ||=  HELP_COMMANDS
      end

      # Displays the help header; override this if you want to customize
      # your own help header in your subclass.
      def help_header
        say "#{name} Help", HIGHLIGHT
        say '---', HIGHLIGHT
      end

      # Override this in your subclass and call super AFTER you've
      # displayed your subclass' help body.
      def help_body
        say "[#{HELP_COMMANDS.join(' | ')}] Display help", HIGHLIGHT
        say "[#{BACK_COMMANDS.join(' | ')}] Go back", HIGHLIGHT if parent?
        say "[#{EXIT_COMMANDS.join(' | ')}] Exit", HIGHLIGHT unless parent?
      end

      # This simply outputs our prompt and accepts user input.
      def ask
        super full_prompt
      end

      def unrecognized_command(command)
        say "Unrecognized command (\"#{command}\"). Try again.", ERROR
      end

      # Builds the full prompt to be used which amounts to:
      # <parent cli prompt> PROMPT_TOKEN <child cli 1 prompt>
      # PROMPT_TOKEN <child 2 cli prompt> ...
      def full_prompt_build(prompts:)
        parent.send(:full_prompt_build, prompts: prompts) if parent?

        prompts << prompt
        prompts.flatten
      end
    end
  end
end
