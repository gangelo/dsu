# frozen_string_literal: true

require_relative '../models/configuration'
require_relative '../views/configuration/show'
require_relative '../views/shared/model_errors'
require_relative '../views/shared/success'
require_relative '../views/shared/warning'
require_relative 'base_subcommand'

module Dsu
  module Subcommands
    class Config < BaseSubcommand
      default_command :help

      class << self
        def exit_on_failure?
          false
        end
      end

      desc I18n.t('cli.subcommands.config.info.desc'), I18n.t('cli.subcommands.config.info.usage')
      long_desc I18n.t('cli.subcommands.config.info.long_desc')
      def info
        configuration = Models::Configuration.new
        Views::Configuration::Show.new(config: configuration).call
      end

      if Dsu.env.development?
        desc I18n.t('cli.subcommands.config.init.desc'), I18n.t('cli.subcommands.config.init.usage')
        long_desc I18n.t('cli.subcommands.config.init.long_desc', home_folder: Dsu::Support::Fileable.root_folder)
        def init
          exit 1 if configuration_errors_or_wanings?

          Models::Configuration.default.tap do |configuration|
            configuration.save!
            messages = [I18n.t('messages.configuration_file.created',
              configuration_file: Models::Configuration.config_file)]
            Views::Shared::Success.new(messages: messages).render
            Views::Configuration::Show.new(config: configuration).render
          end
        end

        desc I18n.t('cli.subcommands.config.delete.desc'), I18n.t('cli.subcommands.config.delete.usage')
        long_desc I18n.t('cli.subcommands.config.delete.long_desc')
        def delete
          unless Models::Configuration.exist?
            messages = [I18n.t('messages.configuration_file.does_not_exist',
              configuration_file: Models::Configuration.config_file)]
            Views::Shared::Warning.new(messages: messages).render
            exit 1
          end
          Models::Configuration.delete!
          messages = [I18n.t('messages.configuration_file.deleted',
            configuration_file: Models::Configuration.config_file)]
          Views::Shared::Success.new(messages: messages).render
        end
      end

      private

      def configuration_errors_or_wanings?
        if Models::Configuration.exist?
          messages = [I18n.t('messages.configuration_file.already_exists',
            configuration_file: Models::Configuration.config_file)]
          Views::Shared::Warning.new(messages: messages).render
        elsif !Dir.exist?(Models::Configuration.config_folder)
          messages = [I18n.t('messages.configuration_file.destination_folder_does_not_exist',
            configuration_file: Models::Configuration.config_file)]
          Views::Shared::Error.new(messages: messages).render
        else
          configuration = Models::Configuration.default
          return false if configuration.valid?

          Views::Shared::ModelErrors.new(model: configuration).render
        end

        true
      end
    end
  end
end
