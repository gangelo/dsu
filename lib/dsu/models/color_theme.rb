# frozen_string_literal: true

require 'active_model'
require_relative '../models/configuration'
require_relative '../support/descriptable'
require_relative '../validators/description_validator'

module Dsu
  module Models
    # This class represents a dsu color theme.
    class ColorTheme
      include ActiveModel::Model
      include Support::Descriptable

      DEFAULT_THEME = {
        version: '1.0.0',
        description: 'Default theme',
        entry_group: :highlight,
        entry: :highlight,
        status_info: :cyan,
        status_success: :green,
        status_warning: :yellow,
        status_error: :red,
        state_highlight: :cyan
      }.freeze
      DEFAULT_THEME_NAME = 'default'

      # TODO: Validate theme colors against valid colorize
      # gem colors.
      validates_with Validators::DescriptionValidator

      attr_reader :theme_name

      def initialize(theme_name:, theme_hash: {})
        raise ArgumentError, 'theme_name is nil.' if theme_name.nil?
        raise ArgumentError, "theme_name is the wrong object type: \"#{theme_name}\"." unless theme_name.is_a?(String)

        @theme_name = theme_name
        ensure_theme_hash! theme_hash

        # Color themes I expect will change a lot, so we're using
        # a little meta-programming here to dynamically create
        # public attr_readers and private attr_writers based on the
        # keys in DEFAULT_THEME, then assign those attributes from
        # the values in theme_hash. theme_hash will be guaranteed to
        # have the same keys as DEFAULT_THEME.keys at this point
        # because we called ensure_theme_hash! above.
        DEFAULT_THEME.each_key do |attr|
          self.class.class_eval do
            attr_reader attr
            attr_writer attr
            private "#{attr}="
          end
          send("#{attr}=", theme_hash[attr])
        end
      end

      class << self
        def version
          DEFAULT_THEME[:version]
        end

        # Returns the current color theme if it exists; otherwise,
        # it returns the default color theme.
        def current_or_default
          current || default
        end

        def current
          # TODO: Implement this.
        end

        def default
          new(theme_name: DEFAULT_THEME_NAME, theme_hash: DEFAULT_THEME)
        end

        def theme_file_exist?(theme_name:)
          File.exist?(theme_file(theme_name: theme_name))
        end

        def theme_file(theme_name:)
          File.join(themes_folder, theme_name)
        end

        def themes_folder
          configuration.themes_folder
        end

        private

        def configuration
          @configuration ||= Models::Configuration.current_or_default
        end
      end

      def theme_file_exist?
        self.class.theme_file_exist?(theme_name: @theme_name)
      end

      def theme_file
        self.class.theme_file(theme_name: @theme_name)
      end

      def themes_folder
        self.class.themes_folder
      end

      def to_h
        {}.tap do |hash|
          DEFAULT_THEME.each_key do |key|
            hash[key] = public_send(key)
          end
        end
      end

      # Override == and hash so that we can compare Entry objects based
      # on description alone. This is useful for comparing entries in
      # an array, for example.
      def ==(other)
        return false unless other.is_a?(self.class)
        return false unless other.theme_name == theme_name

        DEFAULT_THEME.keys.all? { |key| public_send(key) == other.public_send(key) }
      end
      alias eql? ==

      def hash
        hashes = DEFAULT_THEME.keys.map { |key| public_send(key) }
        hashes << theme_name.hash
        hashes.hash
      end

      def save!
        validate!

        Services::ColorTheme::WriterService.new(theme_name: theme_name, theme_hash: to_h).call
      end

      private

      # This method ensures that theme_hash is a valid color theme hash.
      # Apart from the obvious guard clauses, it also ensures that
      # theme_hash.keys == DEFAULT_THEME.keys. If not, it raises an
      # ArgumentError displaying the missing and extra keys present in
      # hash_keys as compared to DEFAULT_THEME.keys.
      def ensure_theme_hash!(theme_hash)
        raise ArgumentError, 'theme_hash is nil.' if theme_hash.nil?
        raise ArgumentError, "theme_hash is the wrong object type: \"#{theme_hash}\"." unless theme_hash.is_a?(Hash)

        theme_hash_keys = theme_hash.keys.sort
        expected_keys = DEFAULT_THEME.keys.sort

        return if theme_hash_keys == expected_keys

        missing_keys = expected_keys - theme_hash_keys
        extra_keys = theme_hash_keys - expected_keys

        raise ArgumentError, 'theme_hash keys are missing or invalid: ' \
                             "expected: #{expected_keys.to_token_string}, " \
                             "missing: #{missing_keys.to_token_string}, " \
                             "extra: #{extra_keys.to_token_string}"
      end
    end
  end
end
