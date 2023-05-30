# frozen_string_literal: true

require 'psych'
require_relative '../../support/configuration_fileable'

module Dsu
  module Services
    module Configuration
      # This service is used to write the configuration file.
      class WriterService
        include Support::ConfigurationFileable

        def initialize(config_hash:)
          raise ArgumentError, 'config_hash cannot be nil' if config_hash.nil?
          raise ArgumentError, 'config_hash must be a Hash' unless config_hash.is_a?(Hash)

          @config_hash = config_hash.dup
        end

        def call
          # TODO: Validate the Configuration here once it is promoted
          # to a class object; i.e.:
          # confuguration.validate!

          write_file!

          config_hash
        end

        private

        attr_reader :config_hash

        def write_file!
          File.write(config_file, Psych.dump(config_hash.to_h))
        end
      end
    end
  end
end
