# frozen_string_literal: true

require_relative '../models/configuration'

module Dsu
  module Support
    # This module provides a way to configure a class, so that it can
    # be used in a test environment.
    # TODO: Get rid of this?
    module Configurable
      def configuration
        @configuration ||= Models::Configuration.current_or_default
      end
    end
  end
end
