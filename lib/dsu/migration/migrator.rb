# frozen_string_literal: true

require_relative '../env'
require_relative 'version'

module Dsu
  module Migration
    class Migrator
      class << self
        def migrate_if!(migration_services: [])
          return if migration_services.any? do |migration_service|
            migration_service.migrate_if!
            migration_service.class.migrates_to_latest_migration_version?
          end

          raise I18n.t('migrations.error.missing_current_migration_service', migration_version: Migration::VERSION)
        rescue StandardError => e
          puts I18n.t('migrations.error.failed', message: e.message)
          exit 1 unless Dsu.env.test?
        end
      end
    end
  end
end
