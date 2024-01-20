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
          if presenter.respond response: response
            display_project_created_message
          else
            display_project_cancelled_message
          end
        rescue StandardError => e
          puts apply_theme(e.message, theme_color: color_theme.error)
        end

        private

        attr_reader :presenter, :color_theme, :options

        def project_name
          presenter.project_name
        end

        def display_project_cancelled_message
          message = I18n.t('subcommands.project.messages.cancelled', project_name: project_name)
          puts apply_theme(message, theme_color: color_theme.info)
        end

        def display_project_create_prompt
          response = ask_while(prompt_with_options(prompt: create_prompt,
            options: create_prompt_options), options: options) do |input|
            message = I18n.t('information.input.try_again', options: create_prompt_options.join(','))
            puts apply_theme(message, theme_color: color_theme.info) unless create_prompt_options.include?(input)
            create_prompt_options.include?(input)
          end
          response == create_prompt_options.first
        end

        def display_project_created_message
          message = I18n.t('subcommands.project.create.messages.created', project_name: project_name)
          puts apply_theme(message, theme_color: color_theme.success)
        end

        def display_project_errors
          errors = presenter.project_errors.join("\n")
          puts apply_theme(errors, theme_color: color_theme.error)
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
