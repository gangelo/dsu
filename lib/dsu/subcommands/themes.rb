# frozen_string_literal: true

require_relative '../base_cli'
require_relative '../models/color_theme'
require_relative '../support/ask'

module Dsu
  module Subcommands
    class Themes < Dsu::BaseCLI
      include Support::Ask

      map %w[c] => :create
      map %w[e] => :edit
      map %w[d] => :delete
      map %w[l] => :list
      map %w[v] => :view
      map %w[u] => :use

      desc 'use, u THEME_NAME',
        'Sets THEME_NAME as the current DSU color theme.'
      long_desc <<-LONG_DESC
        Sets THEME_NAME as the current DSU color theme.
      LONG_DESC
      def use(theme_name)
        unless Models::ColorTheme.exist?(theme_name: theme_name)
          prompt = color_theme.prompt_with_options(prompt: "Color theme \"#{theme_name}\" does not exist. Create it?",
            options: %w[y N])
          message_header = if yes?(prompt)
            Models::ColorTheme.find_or_create(theme_name: theme_name)
            "Created color theme \"#{theme_name}\"."
          else
            theme_name = configuration.theme_name
            'Canceled.'
          end
        end
        configuration.theme_name = theme_name
        configuration.save!
        Views::Shared::Messages.new(messages: "Using color theme \"#{theme_name}\".", message_type: :info, options: { header: message_header }).render
      end
    end
  end
end
