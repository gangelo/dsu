# frozen_string_literal: true

require_relative '../models/color_theme'
require_relative '../support/ask'
require_relative '../support/color_themable'

module Dsu
  module Views
    class Import
      include Support::Ask
      include Support::ColorThemable

      def initialize(presenter:, options:)
        @presenter = presenter
        @options = options&.dup || {}
        @color_theme = Models::ColorTheme.find(theme_name: theme_name)
      end

      def render
        return display_nothing_to_import_message if presenter.nothing_to_import?

        response = display_import_prompt
        if presenter.respond response: response
          display_import_messages presenter.import_messages
        else
          display_cancelled_message
        end
      rescue StandardError => e
        puts apply_theme(e.message, theme_color: color_theme.error)
        puts apply_theme(e.backtrace_locations.join("\n"), theme_color: color_theme.error) if Dsu.env.local?
      end

      private

      attr_reader :presenter, :color_theme, :options

      def project_name
        presenter.project_name
      end

      def display_import_prompt
        response = ask_while(prompt_with_options(prompt: import_prompt,
          options: import_prompt_options), options: options) do |input|
          message = I18n.t('information.input.try_again', options: import_prompt_options.join(','))
          puts apply_theme(message, theme_color: color_theme.info) unless import_prompt_options.include?(input)
          import_prompt_options.include?(input)
        end
        response == import_prompt_options.first
      end

      def display_cancelled_message
        puts apply_theme(I18n.t('subcommands.import.messages.cancelled'), theme_color: color_theme.info)
      end

      def display_nothing_to_import_message
        puts apply_theme(I18n.t('subcommands.import.messages.nothing_to_import'), theme_color: color_theme.info)
      end

      def import_prompt
        I18n.t('subcommands.import.prompts.import_all_confirm',
          count: presenter.import_entry_groups_count, project: presenter.project_name)
      end

      def import_prompt_options
        I18n.t('subcommands.import.prompts.options')
      end

      def display_import_file_not_exist_message
        puts apply_theme(I18n.t('subcommands.import.messages.file_not_exist',
          file_path: import_file_path), theme_color: color_theme.info)
      end

      def display_import_messages(import_results)
        import_results.each_pair do |entry_group_date, errors|
          if errors.empty?
            puts apply_theme(I18n.t('subcommands.import.messages.import_success',
              date: entry_group_date), theme_color: color_theme.success)
          else
            errors.each do |error|
              puts apply_theme(I18n.t('subcommands.import.messages.import_error',
                date: entry_group_date, error: error), theme_color: color_theme.error)
            end
          end
        end
      end

      def theme_name
        @theme_name ||= options.fetch(:theme_name, Models::Configuration.new.theme_name)
      end
    end
  end
end
