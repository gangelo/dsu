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
          return apply_color_theme("Configuration file (#{config_path}) contents:",
            color_theme_color: color_theme.success.underline!)
        end

        [
          apply_color_theme("Configuration file (#{config_path}) does not exist.",
            color_theme_color: color_theme.warning),
          apply_color_theme('The default configuration is being used:',
            color_theme_color: color_theme.warning.underline!),
        ].join("\n")
      end

      def configuration_details
        color = if exist?
          color_theme.success
        else
          color_theme.warning
        end
        to_h.each_with_index.filter_map do |config_entry, index|
          formatted_config_entry_with_index(config_entry, index: index, color_theme_color: color)
        end
      end

      private

      def config_path
        @config_path ||= config.class.config_path
      end

      def formatted_config_entry_with_index(config_entry, index:, color_theme_color:)
        "#{formatted_index(index: index,
          color_theme_color: color_theme_color)} #{formatted_config_entry(config_entry: config_entry,
            color_theme_color: color_theme_color)}"
      end

      def formatted_config_entry(config_entry:, color_theme_color:)
        config_entry = "#{config_entry[0]}: '#{config_entry[1]}'"
        apply_color_theme(config_entry, color_theme_color: color_theme_color.light!)
      end

      def formatted_index(index:, color_theme_color:)
        apply_color_theme("#{format('%03s', index + 1)}. ",
          color_theme_color: color_theme_color)
      end
    end
  end
end
