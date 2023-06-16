# frozen_string_literal: true

require_relative '../support/color_themable'
require_relative 'base_presenter'

module Dsu
  module Presenters
    class ConfigurationPresenter < BasePresenter
      attr_reader :config

      def initialize(config)
        super

        @config = config
      end

      def configuration_exists_header
        if exist?
          return apply_color_theme("Configuration file contents (#{config_path})",
            color_theme_color: color_theme.header)
        end

        [
          apply_color_theme("Configuration file does not exist (#{config_path})",
            color_theme_color: color_theme.header),
          apply_color_theme('The default configuration is being used:',
            color_theme_color: color_theme.warning)
        ].join("\n")
      end

      def configuration_details
        to_h.each_with_index.filter_map do |config_entry, index|
          formatted_config_entry_with_index(config_entry, index: index, color_theme_color: color_theme.body)
        end
      end

      private

      def config_path
        @config_path ||= config.class.config_path
      end

      def formatted_config_entry_with_index(config_entry, index:, color_theme_color:)
        "#{formatted_index(index: index)} #{formatted_config_entry(config_entry: config_entry,
          color_theme_color: color_theme_color)}"
      end

      def formatted_config_entry(config_entry:, color_theme_color:)
        config_entry = "#{config_entry[0]}: '#{config_entry[1]}'"
        apply_color_theme(config_entry, color_theme_color: color_theme_color.light!)
      end
    end
  end
end
