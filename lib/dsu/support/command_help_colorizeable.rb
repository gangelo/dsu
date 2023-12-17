# frozen_string_literal: true

require_relative '../models/color_theme'
require_relative '../support/color_themable'

module Dsu
  module Support
    module CommandHelpColorizable
      class << self
        def included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          # Handles general help colorization.
          def help(shell, subcommand = false) # rubocop:disable Style/OptionalBooleanParameter
            help_text = Services::StdoutRedirectorService.call { super }
            puts apply_theme(help_text, theme_color: color_theme.help)
          end

          # Handles sub-command help colorization.
          def command_help(shell, subcommand = false) # rubocop:disable Style/OptionalBooleanParameter
            help_text = Services::StdoutRedirectorService.call { super }
            puts apply_theme(help_text, theme_color: color_theme.help)
          end

          def color_theme
            @color_theme ||= Models::ColorTheme.current_or_default
          end
        end
      end
    end
  end
end
