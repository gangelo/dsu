# frozen_string_literal: true

require 'json'
require_relative '../../support/fileable'
require_relative '../service'

module Dsu
  module Migration
    module Version10
      # This is the base class for all migration services.
      class MigrationService < Migration::Service
        def version
          File.basename(__dir__).to_f
        end

        def call
          update_migration_version!
        end

        def migrate?
          migration_version > current_migration_version
        end

        private

        # This updates the migration version file with the current migration version.
        # This method is called from the #call method; however, you can call it directly
        # if your subclass does not need to call super#call for some reason, but still
        # want to mark the migration as having run.
        def update_migration_version!
          return unless migrate?

          migration_version_path = Support::Fileable.migration_version_path
          File.write(migration_version_path, JSON.pretty_generate({ migration_version: migration_version }))
        end

        def migration_version
          # This method must be overridden and return the migration version of the
          # current migration file.
          raise NotImplementedError, 'You must implement the #migration_version method.'
        end
      end
    end
  end
end
