# frozen_string_literal: true

module Dsu
  module Support
    module Commander
      # Subcommands should extend this module once they are instantiated
      # so that the Subcommand instance has access to all necessary
      # class methods for this subcommand to work.
      module Subcommand
        class << self
          def extended(mod)
            mod.singleton_class.delegate :command_namespace, :commands,
              :command_add, :command_subcommand_add, :command_prompt, :help, to: mod.class
          end
        end

        # Subcommand-specific instance methods.
        #
        # Define Subcommand-specific method equivalents of the Command class
        # methods needed to make this Subcommand instance unique.

        # def command_namespace(namespace = nil)
        #   return @command_namespace || name if namespace.nil?

        #   @command_namespace = namespace
        # end

        # Subcommands can be used by any Command, so the :command_parent needs
        # to be unique to this Subcommand instance.
        def command_parent(parent = nil)
          return @command_prompt if parent.nil?

          @command_prompt = parent
        end

        def command_namespaces(namespaces = [])
          command_parent&.command_namespaces(namespaces)

          namespaces << command_namespace
          namespaces
        end
      end
    end
  end
end
