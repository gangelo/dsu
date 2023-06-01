# frozen_string_literal: true

require_relative '../../models/configuration'

# This class is responsible for deleting the configuration file.
module Dsu
  module Services
    module Configuration
      class DeleterService
        def initialize(options: {})
          @options = options || {}
        end

        def call
          delete_file!
        end

        private

        attr_reader :options

        def delete_file!
          # TODO: Raise an error if the file does not exist?
          return unless Models::Configuration.config_file_exist?

          File.delete(Models::Configuration.config_file)
        end
      end
    end
  end
end
