# frozen_string_literal: true

require_relative 'use'

module Dsu
  module Views
    module Project
      class UseByNumber < Use
        private

        def display_project_does_not_exist
          message = I18n.t('subcommands.project.messages.number_does_not_exist',
            project_number: presenter.project_number)
          puts apply_theme(message, theme_color: color_theme.error)
        end
      end
    end
  end
end
