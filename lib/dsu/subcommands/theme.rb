# frozen_string_literal: true

require_relative '../env'
require_relative '../support/fileable'
require_relative '../views/color_theme/index'
require_relative '../views/color_theme/show'
require_relative '../views/shared/error'
require_relative '../views/shared/info'
require_relative 'base_subcommand'

module Dsu
  module Subcommands
    class Theme < BaseSubcommand
      map %w[c] => :create if Dsu.env.local?
      map %w[d] => :delete if Dsu.env.local?
      map %w[l] => :list
      map %w[s] => :show
      map %w[u] => :use

      if Dsu.env.local?
        desc I18n.t('subcommands.theme.create.desc'), I18n.t('subcommands.theme.create.usage')
        long_desc I18n.t('subcommands.theme.create.long_desc', themes_folder: Support::Fileable.themes_folder)
        option :description, type: :string, aliases: '-d', banner: 'DESCRIPTION'
        option :prompts, type: :hash, default: {}, hide: true, aliases: '-p'
        def create(theme_name)
          if Models::ColorTheme.exist?(theme_name: theme_name)
            message = I18n.t('subcommands.theme.create.errors.already_exists', theme_name: theme_name)
            Views::Shared::Error.new(messages: message).render
            return false
          end
          prompt_string = I18n.t('subcommands.theme.create.prompts.create_theme', theme_name: theme_name)
          prompt = color_theme.prompt_with_options(prompt: prompt_string, options: %w[y N])
          if yes?(prompt, options: options)
            theme_hash = Models::ColorTheme::DEFAULT_THEME.dup
            theme_hash[:description] = options[:description] || I18n.t('subcommands.theme.generic.color_theme',
              theme_name: theme_name.capitalize)
            Models::ColorTheme.new(theme_name: theme_name, theme_hash: theme_hash).save!
            message = I18n.t('subcommands.theme.create.messages.created', theme_name: theme_name)
            Views::Shared::Info.new(messages: "\n#{message}").render
            true
          else
            message = I18n.t('subcommands.theme.create.messages.canceled')
            Views::Shared::Info.new(messages: "\n#{message}").render
            false
          end
        end

        desc I18n.t('subcommands.theme.delete.desc'), I18n.t('subcommands.theme.delete.usage')
        long_desc I18n.t('subcommands.theme.delete.long_desc', themes_folder: Support::Fileable.themes_folder)
        option :prompts, type: :hash, default: {}, hide: true, aliases: '-p'
        def delete(theme_name) # rubocop:disable Metrics/MethodLength
          display_dsu_header

          if theme_name == Models::ColorTheme::DEFAULT_THEME_NAME
            message = I18n.t('subcommands.theme.delete.errors.cannot_delete', theme_name: theme_name)
            Views::Shared::Error.new(messages: message).render
            return
          end

          unless Models::ColorTheme.exist?(theme_name: theme_name)
            message = I18n.t('subcommands.theme.generic.errors.does_not_exist', theme_name: theme_name)
            Views::Shared::Error.new(messages: message).render
            return
          end

          prompt_string = I18n.t('subcommands.theme.delete.prompts.delete_theme', theme_name: theme_name)
          prompt = color_theme.prompt_with_options(prompt: prompt_string, options: %w[y N])
          message = if yes?(prompt, options: options)
            Models::ColorTheme.delete!(theme_name: theme_name)
            change_theme
            I18n.t('subcommands.theme.delete.messages.deleted', theme_name: theme_name)
          else
            I18n.t('subcommands.theme.delete.messages.canceled')
          end
          Views::Shared::Info.new(messages: "\n#{message}").render
        end
      end

      desc I18n.t('subcommands.theme.list.desc'), I18n.t('subcommands.theme.list.usage')
      long_desc I18n.t('subcommands.theme.list.long_desc', themes_folder: Support::Fileable.themes_folder)
      def list
        Views::ColorTheme::Index.new.render
      end

      desc I18n.t('subcommands.theme.use.desc'), I18n.t('subcommands.theme.use.usage')
      long_desc I18n.t('subcommands.theme.use.long_desc')
      option :prompts, type: :hash, default: {}, hide: true, aliases: '-p'
      def use(theme_name = Models::ColorTheme::DEFAULT_THEME_NAME)
        display_dsu_header

        return if Dsu.env.local? && !Models::ColorTheme.exist?(theme_name: theme_name) && !create(theme_name)

        unless Models::ColorTheme.exist?(theme_name: theme_name)
          message = I18n.t('subcommands.theme.generic.errors.does_not_exist', theme_name: theme_name)
          Views::Shared::Error.new(messages: message).render
          return
        end

        change_theme theme_name: theme_name
        # We need to display the header after the theme is updated so that it is displayed in the
        # correct theme color.
        message = I18n.t('subcommands.theme.use.messages.using_color_theme', theme_name: theme_name)
        Views::Shared::Info.new(messages: message).render
      end

      desc I18n.t('subcommands.theme.show.desc'), I18n.t('subcommands.theme.show.usage')
      long_desc I18n.t('subcommands.theme.show.long_desc')
      def show(theme_name = configuration.theme_name)
        if Dsu::Models::ColorTheme.exist?(theme_name: theme_name)
          Views::ColorTheme::Show.new(theme_name: theme_name).render
          return
        end

        message = I18n.t('subcommands.theme.generic.errors.does_not_exist', theme_name: theme_name)
        Views::Shared::Error.new(messages: message).render
      end

      private

      def display_dsu_header
        self.class.display_dsu_header
      end

      def change_theme(theme_name: Models::ColorTheme::DEFAULT_THEME_NAME)
        configuration.theme_name = theme_name
        configuration.save!
      end
    end
  end
end
