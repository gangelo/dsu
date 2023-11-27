# frozen_string_literal: true

require 'active_model'
require_relative '../crud/json_file'
require_relative '../migration/version'
require_relative '../support/fileable'
require_relative '../support/presentable'
require_relative '../validators/version_validator'

module Dsu
  module Models
    # This class represents the dsu configuration.
    class Configuration < Crud::JsonFile
      include Support::Fileable
      include Support::Presentable

      VERSION = Migration::VERSION

      DEFAULT_CONFIGURATION = {
        version: VERSION,
        # The default editor to use when editing entry groups if the EDITOR
        # environment variable on your system is not set. On nix systmes,
        # the default editor is`nano`. You need to change this default on
        # Windows systems.
        editor: 'nano',
        # The order by which entries should be displayed by default:
        # :asc or :desc, ascending or descending, respectively.
        entries_display_order: :desc,
        carry_over_entries_to_today: false,
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
        include_all: false,
        # Themes
        # The currently selected color theme. Should be equal to
        # Models::ColorTheme::DEFAULT_THEME_NAME or the name of a custom
        # theme (with the same file name) that resides in the themes_folder.
        theme_name: 'default'
      }.freeze

      validates_with Validators::VersionValidator
      validates :editor, presence: true
      validates :entries_display_order, presence: true,
        inclusion: { in: %i[asc desc], message: 'must be :asc or :desc' }
      validates :carry_over_entries_to_today, inclusion: { in: [true, false], message: 'must be true or false' }
      validates :include_all, inclusion: { in: [true, false], message: 'must be true or false' }
      validates :theme_name, presence: true
      validate :validate_theme_file

      attr_accessor :version,
        :editor,
        :entries_display_order,
        :carry_over_entries_to_today,
        :include_all,
        :theme_name

      attr_reader :options

      def initialize(options: {})
        super(config_path)

        FileUtils.mkdir_p config_folder

        @options = options || {}
        reload

        write! unless exist?
      end

      # Temporarily sets the configuration to the given config_hash.
      # To reset the configuration to its original state, call #reload
      def replace!(config_hash: {})
        raise ArgumentError, 'config_hash is nil.' if config_hash.nil?
        raise ArgumentError, "config_hash must be a Hash: \"#{config_hash}\"." unless config_hash.is_a?(Hash)

        assign_attributes_from config_hash.dup

        self
      end

      # Restores the configuration to its original state from disk.
      def reload
        file_hash = if exist?
          read do |config_hash|
            hydrated_hash = Services::Configuration::HydratorService.new(config_hash: config_hash).call
            config_hash.merge!(hydrated_hash)
          end
        else
          DEFAULT_CONFIGURATION.dup
        end

        assign_attributes_from file_hash

        self
      end

      def carry_over_entries_to_today?
        carry_over_entries_to_today
      end

      def to_h
        {
          version: version,
          editor: editor,
          entries_display_order: entries_display_order,
          carry_over_entries_to_today: carry_over_entries_to_today,
          include_all: include_all,
          theme_name: theme_name
        }
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
          public_send(key)
        end.hash
      end

      def merge(hash)
        hash.transform_keys!(&:to_sym)
        replace!(config_hash: to_h.merge(hash))
      end

      private

      def assign_attributes_from(config_hash)
        @version = config_hash.fetch(:version, VERSION)
        @editor = config_hash.fetch(:editor, DEFAULT_CONFIGURATION[:editor])
        @entries_display_order = config_hash.fetch(:entries_display_order,
          DEFAULT_CONFIGURATION[:entries_display_order])
        @carry_over_entries_to_today = config_hash.fetch(:carry_over_entries_to_today,
          DEFAULT_CONFIGURATION[:carry_over_entries_to_today])
        @include_all = config_hash.fetch(:include_all, DEFAULT_CONFIGURATION[:include_all])
        @theme_name = config_hash.fetch(:theme_name, DEFAULT_CONFIGURATION[:theme_name])
      end

      def validate_theme_file
        theme_path = themes_path(theme_name: theme_name)
        return if File.exist?(theme_path)

        i18n_key = 'configuration.errors.theme_file_missing'
        errors.add(:base, I18n.t(i18n_key, theme_path: theme_path))
      end
    end
  end
end
