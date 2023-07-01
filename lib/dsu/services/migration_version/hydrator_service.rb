# frozen_string_literal: true

module Dsu
  module Services
    module MigrationVersion
      class HydratorService
        def initialize(migration_version_json:, options: {})
          raise ArgumentError, 'migration_version_json is nil' if migration_version_json.nil?

          unless migration_version_json.is_a?(String)
            raise ArgumentError,
              "migration_version_json is the wrong object type: \"#{migration_version_json}\""
          end
          raise ArgumentError, 'options is nil' if options.nil?
          raise ArgumentError, "options is the wrong object type:\"#{options}\"" unless options.is_a?(Hash)

          @migration_version_json = migration_version_json
          @options = options || {}
        end

        def call
          hydrate
        end

        private

        attr_reader :migration_version_json, :options

        def hydrate
          JSON.parse(migration_version_json, symbolize_names: true).tap do |hash|
            hash[:migration_version] = hash[:migration_version].to_i
          end
        end
      end
    end
  end
end
