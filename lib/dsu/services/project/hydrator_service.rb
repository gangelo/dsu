# frozen_string_literal: true

require_relative '../../models/color_theme'

module Dsu
  module Services
    module Project
      class HydratorService
        def initialize(project_hash:, options: {})
          raise ArgumentError, 'project_hash is nil' if project_hash.nil?

          unless project_hash.is_a?(Hash)
            raise ArgumentError,
              "project_hash is the wrong object type: \"#{project_hash}\""
          end
          raise ArgumentError, 'options is nil' if options.nil?
          raise ArgumentError, "options is the wrong object type:\"#{options}\"" unless options.is_a?(Hash)

          @project_hash = project_hash
          @options = options || {}
        end

        def call
          Models::Project.new(**hydrate)
        end

        private

        attr_reader :project_hash, :options

        # Not much going on here at all, but it's here for consistency.
        # Perform any pre-processing of the project_hash here (e.g. symbolize keys,
        # convert values to the correct type, etc.).
        def hydrate
          project_hash
        end
      end
    end
  end
end
