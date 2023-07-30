# frozen_string_literal: true

require 'json'
require_relative '../crud/json_file'
require_relative '../migration/version'
require_relative '../support/color_themable'
require_relative '../support/descriptable'
require_relative '../support/fileable'
require_relative '../support/presentable'
require_relative '../validators/color_theme_validator'
require_relative '../validators/description_validator'
require_relative '../validators/version_validator'
require_relative 'configuration'

module Dsu
  module Models
    # This class represents a dsu color theme.
    class ColorTheme < Crud::JsonFile
      include Support::ColorThemable
      include Support::Descriptable
      include Support::Fileable
      include Support::Presentable

      VERSION = Migration::VERSION

      DEFAULT_THEME_NAME = 'default'
      # Theme colors key/value pair format:
      # <key>: { color: <color> [, mode: <mode>] [, background: <background>] }
      # Where <color> (required) == any color represented in the colorize gem `String.colors` array.
      #       <mode> (optional, default is :default) == any mode represented in the colorize gem `String.modes` array.
      #       <background> (optional, default is :default) == any color represented in the colorize gem
      #                    `String.colors` array.
      DEFAULT_THEME_COLORS = {
        help: { color: :cyan },
        dsu_header: { color: :white, mode: :bold, background: :cyan },
        dsu_footer: { color: :cyan },
        header: { color: :cyan, mode: :bold },
        subheader: { color: :cyan, mode: :underline },
        body: { color: :cyan },
        footer: { color: :light_cyan },
        date: { color: :cyan, mode: :bold },
        index: { color: :light_cyan },
        # Status colors.
        info: { color: :cyan },
        success: { color: :green },
        warning: { color: :yellow },
        error: { color: :light_yellow, background: :red },
        # Prompts
        prompt: { color: :cyan, mode: :bold },
        prompt_options: { color: :white, mode: :bold }
      }.freeze
      DEFAULT_THEME = {
        version: VERSION,
        description: 'Default theme.'
      }.merge(DEFAULT_THEME_COLORS).freeze

      # TODO: Validate other attrs.
      validates_with Validators::DescriptionValidator
      validates_with Validators::ColorThemeValidator
      validates_with Validators::VersionValidator

      attr_reader :theme_name

      def initialize(theme_name:, theme_hash: nil)
        raise ArgumentError, 'theme_name is nil.' if theme_name.nil?
        raise ArgumentError, "theme_name is the wrong object type: \"#{theme_name}\"." unless theme_name.is_a?(String)
        unless theme_hash.is_a?(Hash) || theme_hash.nil?
          raise ArgumentError, "theme_hash is the wrong object type: \"#{theme_hash}\"."
        end

        FileUtils.mkdir_p themes_folder

        @theme_name = theme_name

        super(self.class.send(:themes_path_for, theme_name: @theme_name))

        theme_hash ||= DEFAULT_THEME.merge(description: "#{@theme_name.capitalize} theme")

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
          attr_value = theme_hash[attr]
          attr_value = attr_value.merge_default_colors if default_theme_color_keys.include?(attr)
          send("#{attr}=", attr_value)
        end
      end

      class << self
        def all
          Dir.glob("#{themes_folder}/*").map do |file_path|
            theme_name = File.basename(file_path, '.*')
            find(theme_name: theme_name)
          end
        end

        def configuration
          Models::Configuration.instance
        end

        def current
          theme_name = configuration.theme_name
          return unless exist?(theme_name: theme_name)

          find(theme_name: theme_name)
        end

        # Returns the current color theme if it exists; otherwise,
        # it returns the default color theme.
        def current_or_default
          current || default
        end

        def default
          new(theme_name: DEFAULT_THEME_NAME, theme_hash: DEFAULT_THEME)
        end

        def delete(theme_name:)
          superclass.delete(file_path: themes_path_for(theme_name: theme_name))
        end

        def delete!(theme_name:)
          superclass.delete!(file_path: themes_path_for(theme_name: theme_name))
        end

        def ensure_color_theme_color_defaults_for(theme_hash: DEFAULT_THEME)
          theme_hash = theme_hash.dup

          theme_hash.each_pair do |key, value|
            next unless default_theme_color_keys.include?(key)

            theme_hash[key] = value.merge_default_colors
          end
          theme_hash
        end

        def exist?(theme_name:)
          superclass.exist?(file_path: themes_path_for(theme_name: theme_name))
        end

        def find(theme_name:)
          theme_hash = read!(file_path: themes_path_for(theme_name: theme_name))
          Services::ColorTheme::HydratorService.new(theme_name: theme_name, theme_hash: theme_hash).call
        end

        def find_or_create(theme_name:)
          return find(theme_name: theme_name) if exist?(theme_name: theme_name)

          new(theme_name: theme_name).tap(&:write!)
        end

        def find_or_initialize(theme_name:)
          return find(theme_name: theme_name) if exist?(file_name: theme_name)

          new(theme_name: theme_name)
        end

        # TODO: Unused?
        # def build_color_theme(theme_name:, base_color:, description:)
        #   theme_hash = Models::ColorTheme.send(:replace, color_theme: default,
        #     replace_color: :cyan, with_color: base_color).tap do |hash|
        #     hash[:description] = description
        #   end
        #   new(theme_name: theme_name, theme_hash: theme_hash)
        # end

        private

        def default_theme_color_keys
          DEFAULT_THEME_COLORS.keys
        end

        def replace(color_theme:, replace_color:, with_color:)
          colors_theme_hash = color_theme.to_theme_colors_h.tap do |hash|
            hash.each_key do |key|
              hash[key] = replace_color(theme_color: hash[key],
                replace_color: replace_color, with_color: with_color)
            end
          end
          DEFAULT_THEME.merge(colors_theme_hash)
        end

        def replace_color(theme_color:, replace_color:, with_color:)
          %i[color background].each do |color_type|
            color = theme_color[color_type].to_s.sub(replace_color.to_s, with_color.to_s)
            theme_color[color_type] = color.sub('light_light_', 'light_').to_sym
          end
          theme_color
        end

        # If the color theme is deleted (deleted_theme_name) and the current
        # theme_name in the configuration is the same as the deleted theme,
        # we need to reset the configuration theme to the default theme.
        def reset_default_configuration_color_theme_if!(deleted_theme_name:)
          config = configuration
          return if config.theme_name == self::DEFAULT_THEME_NAME
          return unless config.theme_name == deleted_theme_name
          return unless config.exist?

          config.theme_name = self::DEFAULT_THEME_NAME
          config.write!
        end

        def themes_path_for(theme_name:)
          Support::Fileable.themes_path(theme_name: theme_name)
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

      # TODO: Place in a module?
      def prompt_with_options(prompt:, options:)
        options = "[#{options.join('/')}]"
        "#{apply_color_theme(prompt, color_theme_color: self.prompt)} " \
          "#{apply_color_theme(options, color_theme_color: prompt_options)}" \
          "#{apply_color_theme('>', color_theme_color: self.prompt)}"
      end

      private

      attr_writer :theme_name, :description

      def default_theme_color_keys
        @default_theme_color_keys ||= self.class.send(:default_theme_color_keys)
      end
    end
  end
end
