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
          before_command
          super
          after_command
        end

        private

        def before_command
          puts apply_color_theme('Dsu', color_theme_color: color_theme.headers)
          puts
        end

        def after_command
          puts apply_color_theme('______________', color_theme_color: color_theme.footers)
          puts apply_color_theme("dsu v#{Dsu::VERSION}", color_theme_color: color_theme.footers)
        end

        def color_theme
          Models::ColorTheme.current_or_default
        end
      end
    end
  end
end
