# frozen_string_literal: true

require 'time'
require 'active_support/core_ext/numeric/time'
require_relative '../../models/configuration'
require_relative '../../support/color_themable'

module Dsu
  module Views
    module Configuration
      class Show
        include Support::ColorThemable

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
          presenter = Dsu::Models::Configuration.instance.presenter
          puts presenter.configuration_exists_header
          puts presenter.configuration_details
        end
      end
    end
  end
end
