# frozen_string_literal: true

require 'thor'
require_relative '../support/configuration'

module Dsu
  module Subcommands
    class Config < ::Thor
      include Dsu::Support::Configuration

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
        print_config_file
      end

      desc 'init', 'Creates and initializes a .dsu file in your home folder'
      long_desc <<-LONG_DESC
        NAME
        \x5
        `dsu config init` -- will create and initialize a .dsu file
        in the "#{Dsu::Support::FolderLocations.root_folder}" folder.

        SYNOPSIS
        \x5
        dsu config init
      LONG_DESC
      def init
        create_config_file!
      end
    end
  end
end
