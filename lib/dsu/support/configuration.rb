# frozen_string_literal: true

require 'colorize'
require 'fileutils'
require 'yaml'
require_relative 'colors'
require_relative 'location'

module Dsu
  module Support
    module Configuration
      include Colors
      include Location

      CONFIG_FILENAME = '.dsu'

      # rubocop:disable Style/StringHashKeys - YAML writing/loading necessitates this
      DEFAULT_DSU_OPTIONS = {
        'entries' => {
          'entries_location' => "#{Location.entries_folder}/dsu/entries",
          # https://apidock.com/ruby/Time/strftime
          'entries_file_name' => '%Y-%m-%d.json'
        }
      }.freeze
      # rubocop:enable Style/StringHashKeys

      module_function

      def global_config_file
        File.join(global_folder, CONFIG_FILENAME)
      end

      def global_config_file?
        File.exist? global_config_file
      end

      def create_global_config_file!
        create_config_file global_config_file
        print_global_config_file
      end

      def delete_global_config_file!
        delete_config_file global_config_file
      end

      def print_global_config_file
        config_file = global_config_file
        if global_config_file?
          say "Global config file (#{config_file}) contents:", SUCCESS
          print_config_file config_file
        else
          say "Global config file (#{config_file}) does not exist.", WARNING
        end
      end

      private

      def create_config_file(config_file)
        folder = File.dirname(config_file)
        unless Dir.exist?(folder)
          say "Destination folder for configuration file (#{folder}) does not exist", ERROR
          return false
        end

        if File.exist?(config_file)
          say "Configuration file (#{config_file}) already exists", WARNING
          return false
        end

        File.write(config_file, DEFAULT_BRANCH_NAME_OPTIONS.to_yaml)
        say "Configuration file (#{config_file}) created.", SUCCESS

        true
      end

      def delete_config_file(config_file)
        unless File.exist?(config_file)
          say "Configuration file (#{config_file}) does not exist", WARNING
          return false
        end

        File.delete config_file
        say "Configuration file (#{config_file}) deleted", SUCCESS

        true
      end

      def print_config_file(config_file)
        hash = YAML.safe_load(File.open(config_file))
        say hash.to_yaml.gsub("\n-", "\n\n-"), SUCCESS
      end
    end
  end
end
