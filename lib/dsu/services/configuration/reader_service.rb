# frozen_string_literal: true

require 'psych'
require_relative '../../models/configuration'

module Dsu
  module Services
    module Configuration
      # This service is used to read the configuration file from disk
      # or return the default configuration hash if no configuration
      # exists on disk.
      class ReaderService
        def call
          return Models::Configuration::DEFAULT_CONFIG_HASH unless Models::Configuration.config_file_exist?

          read_file
        end

        private

        def read_file
          Psych.safe_load(File.read(Models::Configuration.config_file), [Symbol])
        end
      end
    end
  end
end
