# frozen_string_literal: true

require_relative 'command_help'
require_relative 'subcommand'

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
            binding.pry
            base.singleton_class.delegate :command_namespace, :command_namespaces, :commands,
              :command_add, :command_subcommand_add, :command_prompt, :command_parent,
              :help, to: :engine
          end

          private

          def to_command_namespace_symbol(namespace, join_token: '_')
            namespace.delete(':').split(/(?=[A-Z])/).join(join_token).downcase
          end
        end

        module ClassMethods
          def command_subcommand_create(command_parent:)
            new.tap do |subcommand|
              subcommand.extend Subcommand
              subcommand.command_parent command_parent
            end
          end

          def engine
            @engine ||= Engine.new(owning_command: self)
          end

          class Engine
            include CommandHelp

            attr_reader :owning_command

            def initialize(owning_command:)
              @owning_command = owning_command
            end

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

            def command_subcommand_add(subcommand, command_parent: nil)
              command_parent ||= @owning_command
              subcommand = subcommand.command_subcommand_create command_parent: command_parent
              commands[command_namespace] ||= {}
              binding.pry
              subcommand.command_namespaces.each_with_index do |namespace, index|
                next if index.zero?

                target = commands.dig(*subcommand.command_namespaces[1..index])
                target ||= commands.dig(*subcommand.command_namespaces[0..index - 1])
                target[namespace] ||= {}
              end
              commands.dig(*subcommand.command_namespaces[0..])[subcommand.command_namespaces.last] = subcommand

              # subcommand.commands.each do |command_namespace, command|
              #   command.each do |subcommand_command, data|
              #     commands[self.command_namespace][command_namespace] ||= {}
              #     commands[self.command_namespace][command_namespace][subcommand_command] = {
              #       desc: data[:desc],
              #       long_desc: data[:long_desc],
              #       options: data[:options],
              #       commands: data[:commands],
              #       help: command_help_for(command: subcommand_command, namespaces: subcommand.command_namespaces, desc: data[:desc],
              #         long_desc: data[:long_desc], options: data[:options], commands: data[:commands])
              #     }
              #   end
              # end
            end

            def command_namespaces(namespaces = [])
              command_parent&.command_namespaces(namespaces)

              namespaces << command_namespace
              namespaces
            end

            def command_namespace(namespace = nil)
              return @command_namespace || name if namespace.nil?

              @command_namespace = namespace
            end

            def command_prompt(value = nil)
              return @command_prompt || name if value.nil?

              @command_prompt = value
            end

            def command_parent(parent = nil)
              return @command_parent if parent.nil?

              @command_parent = parent
            end

            def commands
              @commands ||= {}
            end

            def help
              commands.each do |_command, command_data|
                puts "#{command_namespaces.join(' ')} #{command_data[:help]}"
              end
            end
          end
        end
      end
    end
  end
end
