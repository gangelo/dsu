# frozen_string_literal: true

require 'psych'
require_relative '../../models/color_theme'
require_relative '../../support/configurable'

module Dsu
  module Services
    module ColorTheme
      # This service is used to write the color theme file.
      # It is assumed that the theme name and hash has already been validated
      # before using this service.
      class WriterService
        include Support::Configurable

        def initialize(theme_name:, theme_hash:)
          raise ArgumentError, 'theme_name cannot be nil' if theme_name.nil?
          raise ArgumentError, "theme_name must be a String: \"#{theme_name}\"" unless theme_name.is_a?(String)
          raise ArgumentError, 'theme_name cannot be blank' if theme_name.blank?
          raise ArgumentError, 'theme_hash cannot be nil' if theme_hash.nil?
          raise ArgumentError, "theme_hash must be a Hash: \"#{theme_hash}\"" unless theme_hash.is_a?(Hash)
          raise ArgumentError, 'theme_hash cannot be empty' if theme_hash.empty?

          @theme_name = theme_name
          @theme_hash = theme_hash.dup
        end

        def call
          write_file!
        end

        def call!
          raise "Theme file already exists for theme \"#{theme_name}\": \"#{theme_file}\"" if File.exist?(theme_file)

          call
        end

        private

        attr_reader :theme_name, :theme_hash

        def write_file!
          File.write(theme_file, Psych.dump(theme_hash))
        end

        def theme_file
          @theme_file ||= File.join(configuration.themes_folder, theme_name)
        end
      end
    end
  end
end
