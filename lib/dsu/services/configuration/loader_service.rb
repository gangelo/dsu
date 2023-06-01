# frozen_string_literal: true

require_relative '../../models/configuration'

module Dsu
  module Services
    module Configuration
      # This class loads a configuration from disk.
      class LoaderService
        delegate :config_file_exist?, :config_file, to: Models::Configuration

        def initialize(config_hash: nil)
          raise ArgumentError, 'config_hash is nil.' if config_hash.nil?
          raise ArgumentError, "config_hash must be a Hash: \"#{config_hash}\"." unless config_hash.is_a?(Hash)

          @config_hash = config_hash.dup
        end

        def call
          Models::Configuration.new(config_hash: config_hash).tap(&:validate!)
        end

        private

        attr_reader :config_hash
      end
    end
  end
end
