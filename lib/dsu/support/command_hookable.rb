# frozen_string_literal: true

require_relative '../models/color_theme'
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
          super
          display_dsu_footer
        end

        private

        def suspend_header?(args, _options)
          return unless args.count > 1
          return true if args[0] == 'theme' && %w[use delete].include?(args[1])
        end

        def display_dsu_header
          puts apply_color_theme('Dsu', color_theme_color: color_theme.dsu_header)
          puts
        end

        def display_dsu_footer
          puts apply_color_theme('______________', color_theme_color: color_theme.dsu_footer)
          puts apply_color_theme("v#{Dsu::VERSION} | Theme: #{color_theme.theme_name}",
            color_theme_color: color_theme.dsu_footer)
        end

        def color_theme
          Models::ColorTheme.current_or_default
        end
      end
    end
  end
end
