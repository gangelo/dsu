# frozen_string_literal: true

require_relative '../models/configuration'

module Dsu
  module Support
    # This module provides an attr_reader for the current or default
    # configuration.
    module Configurable
      def configuration
        @configuration ||= Models::Configuration.current_or_default
      end
    end
  end
end
