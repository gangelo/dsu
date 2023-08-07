# frozen_string_literal: true

require_relative '../models/color_theme'
require_relative '../services/stderr_redirector_service'
require_relative '../views/shared/error'
require_relative 'color_themable'

module Dsu
  module Support
    module CommandHookable
      class << self
        def included(base)
          base.extend(ColorThemable)
          base.extend(ClassMethods)
        end
      end

      module ClassMethods
        def start(args = ARGV, options = {})
          display_dsu_header unless suspend_header?(args, options)
          stderror = Services::StderrRedirectorService.call do
            super
          end
          display_errors_if(stderror)
          display_dsu_footer
        end

        private

        def suspend_header?(args, _options)
          return unless args.count > 1
          return true if args[0] == 'theme' && %w[use delete].include?(args[1])
        end

        def display_dsu_header
          puts apply_color_theme("Dsu v#{Dsu::VERSION}", color_theme_color: color_theme.dsu_header)
          puts
        end

        def display_dsu_footer
          puts apply_color_theme('_' * 35, color_theme_color: color_theme.dsu_footer)
          footer = apply_color_theme("Theme: #{color_theme.theme_name}", color_theme_color: color_theme.dsu_footer)
          if Dsu.env.development?
            footer = "#{footer} | #{apply_color_theme('Development', color_theme_color: color_theme.error)}"
          end
          puts footer
        end

        def display_errors_if(stderror_string)
          stderror_string = stderror_string.strip
          return unless stderror_string.present?

          errors = stderror_string.split("\n").map(&:strip)
          Views::Shared::Error.new(messages: errors, options: options.merge({ ordered_list: false})).render
        end

        def color_theme
          Models::ColorTheme.current_or_default
        end
      end
    end
  end
end
