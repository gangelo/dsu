# frozen_string_literal: true

require_relative '../models/migration_version'
require_relative 'service_20240210161248'
require_relative 'version'

module Dsu
  module Migration
    class Factory
      class << self
        def migrate_if!(options: {})
          version = options.fetch(:version, migration_version)
          if version == 20230613121411 # rubocop:disable Style/NumericLiterals
            Service20240210161248.new(options: options).migrate!
          end
        end

        private

        def migration_version
          Models::MigrationVersion.new.version
        end
      end
    end
  end
end
