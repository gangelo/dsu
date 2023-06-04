# frozen_string_literal: true

require 'time'
require 'active_support/core_ext/numeric/time'
require_relative '../../models/configuration'
require_relative '../../support/colorable'
require_relative '../../support/say'

module Dsu
  module Views
    module Configuration
      class Show
        include Support::Colorable
        include Support::Say

        def initialize(config:, options: {})
          raise ArgumentError, 'config is nil' if config.nil?
          raise ArgumentError, 'config is the wrong object type' unless config.is_a?(Models::Configuration)
          raise ArgumentError, 'options is nil' if options.nil?
          raise ArgumentError, 'options is the wrong object type' unless options.is_a?(Hash)

          @config = config
          @options = options || {}
        end

        def call
          render!
        end
        alias render call

        private

        attr_reader :config, :options

        def render!
          config_file = Models::Configuration.config_file
          color = if Models::Configuration.exist?
            say "Config file (#{config_file}) contents:", SUCCESS
            SUCCESS
          else
            say "Config file (#{config_file}) does not exist.", WARNING
            say ''
            say 'The default configuration is being used:'
            WARNING
          end
          config.to_h.each_with_index do |config_entry, index|
            say "#{index + 1}. #{config_entry[0]}: '#{config_entry[1]}'", color
          end
        end
      end
    end
  end
end
