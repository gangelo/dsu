# frozen_string_literal: true

require 'psych'
require_relative '../../models/configuration'

module Dsu
  module Services
    module Configuration
      # This service is used to write the configuration file.
      # It is assumed that the configuration hash has already been validated
      # before using this service.
      class WriterService
        def initialize(config_hash:)
          raise ArgumentError, 'config_hash cannot be nil' if config_hash.nil?
          raise ArgumentError, 'config_hash must be a Hash' unless config_hash.is_a?(Hash)

          @config_hash = config_hash.dup
        end

        def call
          write_file!

          config_hash
        end

        private

        attr_reader :config_hash

        def write_file!
          # TODO: Raise an error if the file exists?

          File.write(Models::Configuration.config_file, Psych.dump(config_hash.to_h))
        end
      end
    end
  end
end
