# frozen_string_literal: true

require 'thor'
require_relative '../models/configuration'
require_relative '../views/configuration/show'
require_relative '../views/shared/messages'
require_relative '../views/shared/model_errors'

module Dsu
  module Subcommands
    class Config < ::Thor
      default_command :help

      class << self
        def exit_on_failure?
          false
        end
      end

      desc 'info', 'Displays information about this gem configuration'
      long_desc <<-LONG_DESC
        NAME
        \x5
        `dsu config info` -- Displays information about this gem configuration.

        SYNOPSIS
        \x5
        dsu config info
      LONG_DESC
      def info
        configuration = Models::Configuration.current_or_default
        Views::Configuration::Show.new(config: configuration).call
      end

      desc 'init', 'Creates and initializes a .dsu file in your home folder'
      long_desc <<-LONG_DESC
        NAME

        `dsu config init` -- will create and initialize a .dsu file ("#{Dsu::Support::FolderLocations.root_folder}/.dsu") that you may edit. Otherwise, the default configuration will be used.

        SYNOPSIS

        dsu config init

        CONFIGURATION FILE OPTIONS

        The following configuration file options are available:

        version:

        The configuration version - DO NOT ALTER THIS VALUE!

        editor:

        The default editor to use when editing entry groups if the EDITOR environment variable on your system is not set. The default is 'nano'. You'll need to change the default editor on Windows systems.

        entries_display_order:

        The order by which entries will be displayed, 'asc' or 'desc' (ascending or descending, respectively).

        Default: 'desc'

        entries_file_name:

        The entries file name format. It is recommended that you do not change this. The file name must include `%Y`, `%m` and `%d` `Time` formatting specifiers to make sure the file name is unique and able to be located by `dsu` functions. For example, the default file name is `%Y-%m-%d.json`; however, something like `%m-%d-%Y.json` or `entry-group-%m-%d-%Y.json` would work as well.

        ATTENTION: Please keep in mind that if you change this value `dsu` will not recognize entry files using a different format. You would (at this time), have to manually rename any existing entry file names to the new format.

        Default: '%Y-%m-%d.json'

        entries_folder:

        This is the folder where `dsu` stores entry files. You may change this to anything you want. `dsu` will create this folder for you, as long as your system's write permissions allow this.

        ATTENTION: Please keep in mind that if you change this value `dsu` will not be able to find entry files in any previous folder. You would (at this time), have to manually mode any existing entry files to this new folder.

        Default: "'#{Dsu::Support::FolderLocations.root_folder}/dsu/entries'"
      LONG_DESC
      def init
        exit 1 if configuration_errors_or_wanings?

        Models::Configuration.default.tap do |configuration|
          configuration.save!
          messages = ["Configuration file (#{Models::Configuration.config_file}) created."]
          Views::Shared::Messages.new(messages: messages, message_type: :success).render
          Views::Configuration::Show.new(config: configuration).render
        end
      end

      desc 'delete', 'Deletes the configuration file'
      long_desc <<-LONG_DESC
        NAME
        \x5
        `dsu config delete` -- Deletes the configuration.

        SYNOPSIS
        \x5
        dsu config delete

        NOTES
        \x5
        Deleting the dsu configuration file will simply cause dsu to use the default configuration options (`Dsu::Models::Configuration::DEFAULT_CONFIGURATION`).
      LONG_DESC
      def delete
        unless Models::Configuration.exist?
          messages = ["Configuration file (#{Models::Configuration.config_file}) does not exist."]
          Views::Shared::Messages.new(messages: messages, message_type: :warning).render
          exit 1
        end
        Models::Configuration.delete!
        messages = ["Configuration file (#{Models::Configuration.config_file}) deleted."]
        Views::Shared::Messages.new(messages: messages, message_type: :success).render
      end

      private

      def configuration_errors_or_wanings?
        if Models::Configuration.exist?
          messages = ["Configuration file (#{Models::Configuration.config_file}) already exists"]
          Views::Shared::Messages.new(messages: messages, message_type: :warning).render
        elsif !Dir.exist?(Models::Configuration.config_folder)
          messages = ["Destination folder for configuration file (#{Models::Configuration.config_folder}) does not exist"] # rubocop:disable Layout/LineLength
          Views::Shared::Messages.new(messages: messages, message_type: :error).render
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
