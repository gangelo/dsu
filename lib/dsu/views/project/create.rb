# frozen_string_literal: true

require_relative '../../support/ask'
require_relative '../../support/color_themable'
require_relative '../../models/color_theme'

module Dsu
  module Views
    module Project
      class Create
        include Support::Ask
        include Support::ColorThemable

        def initialize(presenter:, options: {})
          @presenter = presenter
          @options = options&.dup || {}
          @color_theme = Models::ColorTheme.find(theme_name: theme_name)
        end

        def render
          return display_project_errors if presenter.project_errors?
          return display_project_already_exists if presenter.project_already_exists?

          response = display_project_create_prompt
          if presenter.render response: response
            display_project_created_message
          else
            display_cancelled_message
          end
        rescue StandardError => e
          puts apply_theme(e.message, theme_color: color_theme.error)
        end

        private

        attr_reader :presenter, :color_theme, :options

        def project_name
          presenter.project.project_name
        end

        def display_cancelled_message
          message = I18n.t('subcommands.project.create.messages.cancelled', project_name: project_name)
          puts apply_theme(message, theme_color: color_theme.info)
        end

        def display_project_create_prompt
          yes?(prompt_with_options(prompt: create_prompt, options: create_prompt_options), options: options)
        end

        def display_project_created_message
          puts apply_theme(I18n.t('subcommands.project.create.messages.created', project_name: project_name), theme_color: color_theme.info)
        end

        def display_project_errors
          presenter.project.errors.full_messages.each do |error|
            puts apply_theme(error, theme_color: color_theme.error)
          end
        end

        def display_project_already_exists
          message = I18n.t('subcommands.project.create.messages.already_exists', project_name: project_name)
          puts apply_theme(message, theme_color: color_theme.error)
        end

        def create_prompt
          I18n.t('subcommands.project.create.prompts.create_confirm', project_name: project_name)
        end

        def create_prompt_options
          I18n.t('subcommands.project.create.prompts.create_options')
        end

        def theme_name
          @theme_name ||= options.fetch(:theme_name, Models::Configuration.new.theme_name)
        end
      end
    end
  end
end
