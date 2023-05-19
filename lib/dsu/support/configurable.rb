# frozen_string_literal: true

require_relative '../services/configuration_loader_service'

module Dsu
  module Support
    # This module provides a way to configure a class, so that it can
    # be used in a test environment.
    module Configurable
      def configuration
        @configuration ||= Services::ConfigurationLoaderService.new.call
      end
    end
  end
end
