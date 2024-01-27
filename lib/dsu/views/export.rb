# frozen_string_literal: true

require_relative '../models/color_theme'
require_relative '../support/ask'
require_relative '../support/color_themable'

module Dsu
  module Views
    class Export
      include Support::Ask
      include Support::ColorThemable

      def initialize(presenter:, options:)
        @presenter = presenter
        @options = options&.dup || {}
        @color_theme = Models::ColorTheme.find(theme_name: theme_name)
      end

      def render
        return display_nothing_to_export_message if presenter.nothing_to_export?

        response = display_export_prompt
        if presenter.respond response: response
          display_exported_message
          display_exported_to_message(file_path: presenter.export_file_path)
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

      def display_export_prompt
        response = ask_while(prompt_with_options(prompt: export_prompt,
          options: export_prompt_options), options: options) do |input|
          message = I18n.t('information.input.try_again', options: export_prompt_options.join(','))
          puts apply_theme(message, theme_color: color_theme.info) unless export_prompt_options.include?(input)
          export_prompt_options.include?(input)
        end
        response == export_prompt_options.first
      end

      def display_cancelled_message
        puts apply_theme(I18n.t('subcommands.export.messages.cancelled'), theme_color: color_theme.info)
      end

      def display_exported_message
        puts apply_theme(I18n.t('subcommands.export.messages.exported'), theme_color: color_theme.success)
      end

      def display_exported_to_message(file_path:)
        puts apply_theme(I18n.t('subcommands.export.messages.exported_to', file_path: file_path),
          theme_color: color_theme.success)
      end

      def display_nothing_to_export_message
        puts apply_theme(I18n.t('subcommands.export.messages.nothing_to_export'), theme_color: color_theme.info)
      end

      def export_prompt
        I18n.t('subcommands.export.prompts.export_all_confirm', count: presenter.entry_group_count)
      end

      def export_prompt_options
        I18n.t('subcommands.export.prompts.options')
      end

      def theme_name
        @theme_name ||= options.fetch(:theme_name, Models::Configuration.new.theme_name)
      end
    end
  end
end
