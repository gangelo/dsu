# frozen_string_literal: true

module Dsu
  module Services
    module MigrationVersion
      class HydratorService
        def initialize(migration_version_hash:, options: {})
          raise ArgumentError, 'migration_version_hash is nil' if migration_version_hash.nil?

          unless migration_version_hash.is_a?(Hash)
            raise ArgumentError,
              "migration_version_hash is the wrong object type: \"#{migration_version_hash}\""
          end
          raise ArgumentError, 'options is nil' if options.nil?
          raise ArgumentError, "options is the wrong object type:\"#{options}\"" unless options.is_a?(Hash)

          @migration_version_hash = migration_version_hash.dup
          @options = options || {}
        end

        def call
          hydrate
        end

        private

        attr_reader :migration_version_hash, :options

        def hydrate
          migration_version_hash[:version] = migration_version_hash[:version].to_i
          migration_version_hash
        end
      end
    end
  end
end
