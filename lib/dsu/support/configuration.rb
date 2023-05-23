# frozen_string_literal: true

require 'colorize'
require 'fileutils'
require 'yaml'
require_relative 'colorable'
require_relative 'folder_locations'
require_relative 'say'

module Dsu
  module Support
    module Configuration
      include Colorable
      include FolderLocations
      include Say

      CONFIG_FILENAME = '.dsu'

      # rubocop:disable Style/StringHashKeys - YAML writing/loading necessitates this
      DEFAULT_DSU_OPTIONS = {
        # The default editor to use when editing entry groups if the EDITOR
        # environment variable on your system is not set. On nix systmes,
        # the default editor is`nano`. You need to change this default on
        # Windows systems.
        'editor' => 'nano',
        # The order by which entries should be displayed by default:
        # asc or desc, ascending or descending, respectively.
        'entries_display_order' => 'desc',
        'entries_file_name' => '%Y-%m-%d.json',
        'entries_folder' => "#{FolderLocations.root_folder}/dsu/entries",
        'carry_over_entries_to_today' => false,
        # If true, when using dsu commands that list date ranges (e.g.
        # `dsu list dates`), the displayed list will include dates that
        # have no dsu entries. If false, the displayed list will only
        # include dates that have dsu entries.
        # For all other `dsu list` commands, if true, this option will
        # behave in the aforementioned manner. If false, the displayed
        # list will unconditionally display the first and last dates
        # regardless of whether or not the DSU date has entries or not;
        # all other dates will not be displayed if the DSU date has no
        # entries.
        'include_all' => false
      }.freeze
      # rubocop:enable Style/StringHashKeys

      def config_file
        File.join(root_folder, CONFIG_FILENAME)
      end

      def config_file?
        File.exist? config_file
      end

      def create_config_file!
        create_config_file config_file: config_file
        print_config_file
      end

      def delete_config_file!
        delete_config_file config_file: config_file
      end

      # TODO: Move this to a view (e.g. views/configuration/show.rb)
      def print_config_file
        if config_file?
          say "Config file (#{config_file}) contents:", SUCCESS
          hash = YAML.safe_load(File.open(config_file))
          say hash.to_yaml.gsub("\n-", "\n\n-"), SUCCESS
        else
          say "Config file (#{config_file}) does not exist.", WARNING
          say ''
          say 'The default configuration is being used:'
          DEFAULT_DSU_OPTIONS.each_with_index do |config_entry, index|
            say "#{index + 1}. #{config_entry[0]}: '#{config_entry[1]}'"
          end
        end
      end

      private

      def create_config_file(config_file:)
        folder = File.dirname(config_file)
        unless Dir.exist?(folder)
          say "Destination folder for configuration file (#{folder}) does not exist", ERROR
          return false
        end

        if File.exist?(config_file)
          say "Configuration file (#{config_file}) already exists", WARNING
          return false
        end

        File.write(config_file, DEFAULT_DSU_OPTIONS.to_yaml)
        say "Configuration file (#{config_file}) created.", SUCCESS

        true
      end

      def delete_config_file(config_file:)
        unless File.exist?(config_file)
          say "Configuration file (#{config_file}) does not exist", WARNING
          return false
        end

        File.delete config_file
        say "Configuration file (#{config_file}) deleted", SUCCESS

        true
      end
    end
  end
end
