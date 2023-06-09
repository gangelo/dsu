# frozen_string_literal: true

require 'active_model'
require_relative '../crud/color_theme'
require_relative '../support/descriptable'
require_relative '../support/hash_key_comparable'
require_relative '../validators/description_validator'
require_relative '../validators/color_theme_validator'
require_relative '../validators/version_validator'

module Dsu
  module Models
    # This class represents a dsu color theme.
    class ColorTheme
      include ActiveModel::Model
      include Crud::ColorTheme
      include Support::Descriptable
      include Support::HashKeyComparable

      VERSION = '1.0.0'

      DEFAULT_THEME_NAME = 'default'
      # Theme colors key/value pair format:
      # <key>: %i[<color> [[<mode>] [<background>]]]
      # Where <color> (required) == any color represented in the colorize gem `String.colors` array.
      #       <mode> (optional, default is :default) == any mode represented in the colorize gem `String.modes` array.
      #       <background> (optional, default is :default) == any color represented in the colorize gem
      #                    `String.colors` array.
      DEFAULT_THEME_COLORS = {
        # Entry Group colors.
        entry_group_highlight: %i[cyan bold],
        # Entry colors.
        entry_highlight: %i[default bold],
        # Status colors.
        status_info: %i[cyan],
        status_success: %i[green],
        status_warning: %i[yellow],
        status_error: %i[yellow bold red],
        # State colors.
        state_highlight: %i[cyan]
      }.freeze
      DEFAULT_THEME = {
        version: VERSION,
        description: 'Default theme',
      }.merge(DEFAULT_THEME_COLORS).freeze

      # TODO: Validate theme colors against valid colorize
      # gem colors.
      validates_with Validators::DescriptionValidator
      validates_with Validators::ColorThemeValidator
      validates_with Validators::VersionValidator

      attr_reader :theme_name

      def initialize(theme_name:, theme_hash: nil)
        raise ArgumentError, 'theme_name is nil.' if theme_name.nil?
        raise ArgumentError, "theme_name is the wrong object type: \"#{theme_name}\"." unless theme_name.is_a?(String)
        raise ArgumentError, "theme_hash is the wrong object type: \"#{theme_hash}\"." unless theme_hash.is_a?(Hash) || theme_hash.nil?

        @theme_name = theme_name

        theme_hash ||= DEFAULT_THEME.merge(description: "#{theme_name.capitalize} theme")

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
        # Returns the current color theme if it exists; otherwise,
        # it returns the default color theme.
        def current_or_default
          current || default
        end

        def current
          theme_name = configuration.theme_name
          return unless exist?(theme_name: theme_name)

          find(theme_name: theme_name)
        end

        def default
          new(theme_name: DEFAULT_THEME_NAME, theme_hash: DEFAULT_THEME)
        end
      end

      def to_h
        {}.tap do |hash|
          DEFAULT_THEME.each_key do |key|
            hash[key] = public_send(key)
          end
        end
      end

      def to_theme_colors_h
        {}.tap do |hash|
          DEFAULT_THEME_COLORS.each_key do |key|
            hash[key] = public_send(key)
          end
        end
      end

      def ==(other)
        return false unless other.is_a?(self.class)
        return false unless other.theme_name == theme_name

        DEFAULT_THEME.keys.all? { |key| public_send(key) == other.public_send(key) }
      end
      alias eql? ==

      def hash
        DEFAULT_THEME.keys.map { |key| public_send(key) }.tap do |hashes|
          hashes << theme_name.hash
        end.hash
      end
    end
  end
end
