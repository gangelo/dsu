# frozen_string_literal: true

require_relative '../dsu/migration/service'
require_relative '../dsu/models/color_theme'
require_relative '../dsu/models/configuration'
require_relative '../dsu/models/entry'
require_relative '../dsu/models/entry_group'

module Dsu
  module Migrate
    class RemoveAndAddConfigurationAttrs < Migration::Service[1.0]
      def call
        unless migrate?
          raise 'This migration should not be run' \
                "this migration file migration version (#{migration_version}) " \
                "is > the current migration version (#{current_migration_version})."
        end

        # No sense in updating the configuration if it's not saved to disk.
        if Models::Configuration.exist?
          config_folder = Support::Fileable.root_folder
          config_path = File.join(config_folder, '.dsu')
          old_config_hash = Psych.safe_load(File.read(config_path), [Symbol])
          config_hash = Dsu::Models::Configuration::DEFAULT_CONFIGURATION.merge(old_config_hash)
          config_hash.delete('entries_folder')
          config_hash.delete('entries_file_name')
          config_hash.delete('themes_folder')
          config_hash['version'] = migration_version
          binding.pry
          puts config_hash
          Models::Configuration.new(config_hash: config_hash).save!
        else
          Models::Configuration.default.save!
        end

        # TODO: Apply Entry Group/Entry changes here.
        # TODO: Apply Color Theme changes here.

        super
      rescue StandardError => e
        puts "Error running migration #{File.basename(__FILE__)}: #{e.message}"
        raise
      end

      private

      def migration_version
        File.basename(__FILE__).match(Migration::MIGRATION_VERSION_REGEX).try(:[], 0)&.to_i
      end
    end
  end
end

# Run it
migration = Dsu::Migrate::RemoveAndAddConfigurationAttrs.new
migration.call if migration.migrate?
