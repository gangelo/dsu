# frozen_string_literal: true

require_relative 'command_help'

module Dsu
  module Support
    module Commander
      # https://www.toptal.com/ruby/ruby-dsl-metaprogramming-guide
      module Command
        class << self
          def included(base)
            base.extend ClassMethods
            base.engine.command_namespace to_command_namespace_symbol base.name
            base.engine.command_prompt base.engine.command_namespace
            base.singleton_class.delegate :command_namespace, :commands, :command_add,
              :command_subcommand_add, :command_prompt, :command_parent,
              :help, to: :engine
          end

          def to_command_namespace_symbol(namespace, join_token: '_')
            namespace.delete(':').split(/(?=[A-Z])/).join(join_token).downcase
          end
        end

        module ClassMethods
          def engine
            @engine ||= Engine.new
          end

          class Engine
            include CommandHelp

            def command_add(command:, desc:, long_desc: nil, options: {}, commands: [])
              self.commands[command_namespace] ||= {}
              self.commands[command_namespace][command] = {
                desc: desc,
                long_desc: long_desc,
                options: options,
                commands: commands,
                help: command_help_for(command: command, desc: desc,
                  long_desc: long_desc, options: options, commands: commands)
              }
            end

            def command_subcommand_add(subcommand)
              commands[command_namespace] ||= {}
              subcommand[:command].commands.each do |command_namespace, command|
                command.each do |subcommand_command, data|
                  commands[self.command_namespace][command_namespace] ||= {}
                  commands[self.command_namespace][command_namespace][subcommand_command] = {
                    desc: data[:desc],
                    long_desc: data[:long_desc],
                    options: data[:options],
                    commands: data[:commands],
                    help: data[:help]
                  }
                end
              end
            end

            def command_namespace(value = nil)
              return @command_namespace || name if value.nil?

              @command_namespace = value
            end

            def command_prompt(value = nil)
              return @command_prompt || name if value.nil?

              @command_prompt = value
            end

            def command_parent(parent = nil)
              return @command_prompt if parent.nil?

              @command_prompt = parent
            end

            def commands
              @commands ||= {}
            end

            def help
              commands.each do |_command, command_data|
                puts command_data[:help]
              end
            end
          end
        end
      end
    end
  end
end
