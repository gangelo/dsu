# frozen_string_literal: true

require_relative '../support/color_themable'
require_relative 'base_presenter'

module Dsu
  module Presenters
    class ConfigurationPresenter < BasePresenter
      attr_reader :config

      def initialize(config, options: {})
        super

        @config = config
      end

      def configuration_header
        header = I18n.t('presenters.configuration_presenter.headers.file_contents', config_path: config_path)
        apply_theme(header, theme_color: color_theme.header)
      end

      def configuration_details
        to_h.each_with_index.filter_map do |config_entry, index|
          formatted_config_entry_with_index(config_entry, index: index, theme_color: color_theme.body)
        end
      end

      private

      def config_path
        @config_path ||= config.file_path
      end

      def formatted_config_entry_with_index(config_entry, index:, theme_color:)
        "#{formatted_index(index: index)} #{formatted_config_entry(config_entry: config_entry,
          theme_color: theme_color)}"
      end

      def formatted_config_entry(config_entry:, theme_color:)
        config_entry = "#{config_entry[0]}: '#{config_entry[1]}'"
        apply_theme(config_entry, theme_color: theme_color)
      end
    end
  end
end
