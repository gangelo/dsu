# frozen_string_literal: true

require_relative '../support/fileable'
require_relative '../views/color_theme/index'
require_relative '../views/shared/error'
require_relative '../views/shared/info'
require_relative 'base_subcommand'

module Dsu
  module Subcommands
    class Theme < BaseSubcommand
      map %w[c] => :create
      # map %w[e] => :edit
      map %w[d] => :delete
      map %w[l] => :list
      map %w[v] => :view
      map %w[u] => :use

      desc 'create THEME_NAME [OPTIONS]',
        'Creates a dsu color theme named THEME_NAME.'
      long_desc <<-LONG_DESC
      Create a dsu color theme named THEME_NAME in the #{Support::Fileable.themes_folder} folder.

      SYNOPSIS

      `dsu create THEME_NAME [-d|--description DESCRIPTION]`

      OPTIONS:

      -d|--description DESCRIPTION: Creates the dsu color theme with having DESCRIPTION as the color theme description.

      DESCRIPTION:

      Must be be between 2 and 256 characters (inclusive) in length.
      LONG_DESC
      option :description, type: :string, aliases: '-d', banner: 'DESCRIPTION'
      option :prompts, type: :hash, default: {}, hide: true, aliases: '-p'
      def create(theme_name)
        if Models::ColorTheme.exist?(theme_name: theme_name)
          Views::Shared::Error.new(messages: "Color theme \"#{theme_name}\" already exists.").render
          return false
        end
        prompt = color_theme.prompt_with_options(prompt: "Create color theme \"#{theme_name}\"?", options: %w[y N])
        if yes?(prompt, options: options)
          theme_hash = Models::ColorTheme::DEFAULT_THEME.dup
          theme_hash[:description] = options[:description] || "#{theme_name.capitalize} color theme"
          Models::ColorTheme.new(theme_name: theme_name, theme_hash: theme_hash).save!
          Views::Shared::Info.new(messages: "\nCreated color theme \"#{theme_name}\".").render
          true
        else
          Views::Shared::Info.new(messages: "\nCanceled.").render
          false
        end
      end

      desc 'delete THEME_NAME',
        'Deletes the existing dsu color theme THEME_NAME.'
      long_desc <<-LONG_DESC
      NAME

      `dsu delete [THEME_NAME]` -- will delete the dsu color theme named THEME_NAME located in the #{Support::Fileable.themes_folder} folder.
      LONG_DESC
      option :prompts, type: :hash, default: {}, hide: true, aliases: '-p'
      def delete(theme_name)
        display_dsu_header

        if theme_name == Models::ColorTheme::DEFAULT_THEME_NAME
          display_dsu_header
          Views::Shared::Error.new(messages: "Color theme \"#{theme_name}\" cannot be deleted.").render
          return
        end

        unless Models::ColorTheme.exist?(theme_name: theme_name)
          Views::Shared::Error.new(messages: "Color theme \"#{theme_name}\" does not exist.").render
          return
        end

        prompt = color_theme.prompt_with_options(prompt: "Delete color theme \"#{theme_name}\"?",
          options: %w[y N])
        if yes?(prompt, options: options)
          Models::ColorTheme.delete!(theme_name: theme_name)
          Views::Shared::Info.new(messages: "\nDeleted color theme \"#{theme_name}\".").render
        else
          Views::Shared::Info.new(messages: "\nCanceled.").render
        end
      end

      desc 'list',
        'Lists the available dsu color themes.'
      long_desc <<-LONG_DESC
      NAME

      `dsu list` -- lists the available dsu color themes located in the #{Support::Fileable.themes_folder} folder.
      LONG_DESC
      def list
        Views::ColorTheme::Index.new.render
      end

      desc 'use THEME_NAME',
        'Sets THEME_NAME as the current DSU color theme.'
      long_desc <<-LONG_DESC
      NAME

      `dsu theme use [THEME_NAME]` -- sets the dsu color theme to THEME_NAME.

      SYNOPSIS

      If THEME_NAME is not provided, the default theme will be used.
      If THEME_NAME does not exist, you will be given the option to create a new theme.

      LONG_DESC
      option :prompts, type: :hash, default: {}, hide: true, aliases: '-p'
      def use(theme_name = Models::ColorTheme::DEFAULT_THEME_NAME)
        unless Models::ColorTheme.exist?(theme_name: theme_name)
          display_dsu_header
          return unless create(theme_name)
        end

        configuration.theme_name = theme_name
        configuration.save!
        # We need to display the header after the theme is updated so that it is displayed in the
        # correct theme color.
        display_dsu_header
        Views::Shared::Info.new(messages: "Using color theme \"#{theme_name}\".").render
      end

      desc 'view THEME_NAME',
        'Displays the dsu color theme.'
      long_desc <<-LONG_DESC
      NAME

      `dsu view THEME_NAME` -- displays the dsu color theme for THEME_NAME.
      LONG_DESC
      def view(_theme_name)
        # Views::ColorTheme::View.new.(theme_name: theme_name)render
      end

      private

      def display_dsu_header
        self.class.display_dsu_header
      end
    end
  end
end
