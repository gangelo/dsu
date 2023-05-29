# frozen_string_literal: true

require 'active_model'
require_relative '../support/configurable'
require_relative '../support/descriptable'
require_relative '../validators/description_validator'

module Dsu
  module Models
    # This class represents a dsu color theme.
    class ColorTheme
      extend Support::Configurable
      include ActiveModel::Model
      include Support::Descriptable

      DEFAULT_THEME_HASH = {
        version: Dsu::VERSION,
        description: 'Default theme',
        entry_group: :highlight,
        entry: :highlight,
        status_info: :cyan,
        status_success: :green,
        status_warning: :yellow,
        status_error: :red,
        state_highlight: :cyan
      }
      DEFAULT_THEME_NAME = 'default'

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
        # keys in DEFAULT_THEME_HASH, then assign those attributes from
        # the values in theme_hash. theme_hash will be guaranteed to
        # have the same keys as DEFAULT_THEME_HASH.keys at this point
        # because we called ensure_theme_hash! above.
        DEFAULT_THEME_HASH.each_key do |attr|
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
          DEFAULT_THEME_HASH[:version]
        end

        def default
          new(theme_name: DEFAULT_THEME_NAME, theme_hash: DEFAULT_THEME_HASH)
        end

        def theme_file_exist?(theme_name:)
          File.exist?(theme_file(theme_name: theme_name))
        end

        def theme_file(theme_name:)
          File.join(themes_folder, theme_name)
        end

        def themes_folder
          configuration[:themes_folder]
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
          DEFAULT_THEME_HASH.each_key do |key|
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

        DEFAULT_THEME_HASH.keys.all? { |key| public_send(key) == other.public_send(key) }
      end
      alias eql? ==

      def hash
        hashes = DEFAULT_THEME_HASH.keys.map { |key| public_send(key) }
        hashes << theme_name.hash
        hashes.hash
      end

      private

      # This method ensures that theme_hash is a valid color theme hash.
      # Apart from the obvious guard clauses, it also ensures that
      # theme_hash.keys == DEFAULT_THEME_HASH.keys. If not, it raises an
      # ArgumentError displaying the missing and extra keys present in
      # hash_keys as compared to DEFAULT_THEME_HASH.keys.
      def ensure_theme_hash!(theme_hash)
        raise ArgumentError, 'theme_hash is nil.' if theme_hash.nil?
        raise ArgumentError, "theme_hash is the wrong object type: \"#{theme_hash}\"." unless theme_hash.is_a?(Hash)

        theme_hash_keys = theme_hash.keys.sort
        expected_keys = DEFAULT_THEME_HASH.keys.sort

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
