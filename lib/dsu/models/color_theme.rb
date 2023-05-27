# frozen_string_literal: true

require 'active_model'
require_relative '../support/descriptable'
require_relative '../validators/description_validator'
require_relative '..//support/color_theme_locatable'

module Dsu
  module Models
    module ColorTheme
      extend Support::ColorThemeLocatable

      DEFAULT_THEME = {
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

      class << self
        def default
          Theme.new(theme_name: DEFAULT_THEME_NAME, theme_hash: DEFAULT_THEME)
        end

        #   def current
        #     load(theme: :current)
        #   end

        #   def load(theme:)
        #     Theme.load(theme: theme)
        #   end
        def theme_keys
          DEFAULT_THEME.keys
        end
      end

      # This class represents a dsu color theme.
      class Theme
        include ActiveModel::Model
        include Support::Descriptable

        validates_with Validators::DescriptionValidator

        attr_reader :theme_name

        # class << self
        #   # Loads the theme from disk.
        #   def load(theme:)
        #   end
        # end

        def initialize(theme_name:, theme_hash: {})
          raise ArgumentError, 'theme_name is nil.' if theme_name.nil?
          raise ArgumentError, "theme_name is the wrong object type: \"#{theme_name}\"." unless theme_name.is_a?(String)

          @theme_hash = ensure_theme_hash! theme_hash
          @theme_name = theme_name

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

        def to_h
          {}.tap do |hash|
            theme_hash.each_key do |key|
              hash[key] = public_send(key)
            end
          end
        end

        # Override == and hash so that we can compare Entry objects based
        # on description alone. This is useful for comparing entries in
        # an array, for example.
        def ==(other)
          return false unless other.is_a?(Theme)

          DEFAULT_THEME.keys.all? { |key| public_send(key) == other.public_send(key) }
        end
        alias eql? ==

        def hash
          DEFAULT_THEME.keys.map { |key| public_send(key) }.hash
        end

        private

        def theme_hash
          @theme_hash.dup
        end

        # This method ensures that theme_hash is a valid color theme hash.
        # Apart from the obvious guard clauses, it also ensures that
        # theme_hash.keys == DEFAULT_THEME.keys. If not, it raises an
        # ArgumentError displaying the missing and extra keys present in
        # hash_keys as compared to DEFAULT_THEME.keys.
        def ensure_theme_hash!(theme_hash)
          raise ArgumentError, 'theme_hash is nil.' if theme_hash.nil?
          raise ArgumentError, "theme_hash is the wrong object type: \"#{theme_hash}\"." unless theme_hash.is_a?(Hash)

          keys = theme_hash.keys.sort
          expected_keys = DEFAULT_THEME.keys.sort

          return theme_hash if keys == expected_keys

          missing_keys = expected_keys - keys
          extra_keys = keys - expected_keys

          raise ArgumentError, 'theme_hash keys are missing or invalid: ' \
                               "expected: #{theme_hash.keys.to_token_string}, " \
                               "missing: #{missing_keys.to_token_string}, " \
                               "extra: #{extra_keys.to_token_string}"
        end
      end
    end
  end
end
