# frozen_string_literal: true

require 'active_model'
require_relative '../models/color_theme'
require_relative '../services/configuration/deleter_service'
require_relative '../services/configuration/reader_service'
require_relative '../services/configuration/writer_service'
require_relative '../support/folder_locations'

module Dsu
  module Models
    # This class represents the dsu configuration.
    class Configuration
      include ActiveModel::Model

      CONFIG_FILE_NAME = '.dsu'
      ENTRIES_FILE_NAME_REGEX = /\A(?=.*%Y)(?=.*%m)(?=.*%d).*\.json\z/
      VERSION_REGEX = /\A\d+\.\d+\.\d+(\.alpha\.\d+)?\z/

      # rubocop:disable Style/StringHashKeys - YAML writing/loading necessitates this
      DEFAULT_CONFIGURATION = {
        'version' => '1.0.0',
        # The default editor to use when editing entry groups if the EDITOR
        # environment variable on your system is not set. On nix systmes,
        # the default editor is`nano`. You need to change this default on
        # Windows systems.
        'editor' => 'nano',
        # The order by which entries should be displayed by default:
        # asc or desc, ascending or descending, respectively.
        'entries_display_order' => 'desc',
        'entries_file_name' => '%Y-%m-%d.json',
        'entries_folder' => "#{Support::FolderLocations.root_folder}/dsu/entries",
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
        'include_all' => false,
        # Themes
        # The currently selected theme.
        'theme' => Models::ColorTheme::DEFAULT_THEME_NAME,
        # The theme folder where the themes reside.
        'themes_folder' => "#{Support::FolderLocations.root_folder}/dsu/themes"
      }.freeze
      # rubocop:enable Style/StringHashKeys

      validates :version, presence: true,
        format: { with: VERSION_REGEX, message: "must match the format '#.#.#[.alpha.#]' where # is 0-n" }
      validates :editor, presence: true
      validates :entries_display_order, presence: true,
        inclusion: { in: %w[asc desc], message: "must be 'asc' or 'desc'" }
      validates :entries_file_name, presence: true,
        format: { with: ENTRIES_FILE_NAME_REGEX,
                  message: "must include the Time#strftime format specifiers '%Y %m %d' " \
                           'and be a valid file name for your operating system' }
      validates :entries_folder, presence: true
      validate :validate_entries_folder, if: -> { entries_folder.present? }
      validates :carry_over_entries_to_today, inclusion: { in: [true, false], message: 'must be true or false' }
      validates :include_all, inclusion: { in: [true, false], message: 'must be true or false' }
      validates :theme, presence: true
      validate :validate_theme, if: -> { theme.present? }
      validates :themes_folder, presence: true
      validate :validate_themes_folder, if: -> { themes_folder.present? }

      attr_accessor :version,
        :editor,
        :entries_display_order,
        :entries_file_name,
        :entries_folder,
        :carry_over_entries_to_today,
        :include_all,
        :theme,
        :themes_folder

      def initialize(config_hash: {})
        raise ArgumentError, 'config_hash is nil.' if config_hash.nil?
        raise ArgumentError, "config_hash must be a Hash: \"#{config_hash}\"." unless config_hash.is_a?(Hash)

        @config_hash = config_hash.dup
        assign_attributes_from_config_hash
      end

      class << self
        def version
          DEFAULT_CONFIGURATION['version']
        end

        # Returns the current configuration if it exists; otherwise,
        # it returns the default configuration.
        def current_or_default
          current || default
        end

        # Returns the current configuration if it exists or nil.
        def current
          return unless config_file_exist?

          new(config_hash: Services::Configuration::ReaderService.new.call)
        end

        # Returns the default configuration.
        def default
          new(config_hash: DEFAULT_CONFIGURATION)
        end

        def delete!
          Services::Configuration::DeleterService.new.call
        end

        def config_file
          File.join(config_folder, CONFIG_FILE_NAME)
        end

        def config_file_exist?
          File.exist? config_file
        end

        def config_folder
          Support::FolderLocations.root_folder
        end
      end

      def carry_over_entries_to_today?
        carry_over_entries_to_today
      end

      def to_h
        # rubocop:disable Style/StringHashKeys
        {
          'version' => version,
          'editor' => editor,
          'entries_display_order' => entries_display_order,
          'entries_file_name' => entries_file_name,
          'entries_folder' => entries_folder,
          'carry_over_entries_to_today' => carry_over_entries_to_today,
          'include_all' => include_all,
          'theme' => theme,
          'themes_folder' => themes_folder
        }
        # rubocop:enable Style/StringHashKeys
      end

      # Override == and hash so that we can compare objects based
      # on attributes alone. This is also useful for comparing objects
      # in an array, for example.
      def ==(other)
        return false unless other.is_a?(Configuration)

        to_h == other.to_h
      end
      alias eql? ==

      def hash
        DEFAULT_CONFIGURATION.each_key.map do |key|
          public_send(key.to_sym)
        end.hash
      end

      def save!
        validate!

        Services::Configuration::WriterService.new(config_hash: to_h).call
      end

      def delete!
        self.class.delete!
      end

      def merge(hash)
        self.class.new(config_hash: to_h.merge(hash))
      end

      private

      attr_accessor :config_hash

      def assign_attributes_from_config_hash
        @version = config_hash.fetch('version', DEFAULT_CONFIGURATION['version'])
        @editor = config_hash.fetch('editor', DEFAULT_CONFIGURATION['editor'])
        @entries_display_order = config_hash.fetch('entries_display_order',
          DEFAULT_CONFIGURATION['entries_display_order'])
        @entries_file_name = config_hash.fetch('entries_file_name', DEFAULT_CONFIGURATION['entries_file_name'])
        @entries_folder = config_hash.fetch('entries_folder', DEFAULT_CONFIGURATION['entries_folder'])
        @carry_over_entries_to_today = config_hash.fetch('carry_over_entries_to_today',
          DEFAULT_CONFIGURATION['carry_over_entries_to_today'])
        @include_all = config_hash.fetch('include_all', DEFAULT_CONFIGURATION['include_all'])
        @theme = config_hash.fetch('theme', DEFAULT_CONFIGURATION['theme'])
        @themes_folder = config_hash.fetch('themes_folder', DEFAULT_CONFIGURATION['themes_folder'])
      end

      def validate_entries_folder
        return if File.exist?(entries_folder)

        errors.add(:base, "Entries folder \"#{entries_folder}\" does not exist")
      end

      def validate_theme
        theme_file = File.join(themes_folder || 'nil', theme)
        return if File.exist?(theme_file)

        errors.add(:base, "Theme file \"#{theme_file}\" does not exist")
      end

      def validate_themes_folder
        return if Dir.exist?(themes_folder)

        errors.add(:base, "Themes folder \"#{themes_folder}\" does not exist")
      end
    end
  end
end
