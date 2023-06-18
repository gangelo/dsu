# frozen_string_literal: true

require_relative '../dsu/migration/service'
require_relative '../dsu/models/color_theme'
require_relative '../dsu/models/configuration'
require_relative '../dsu/models/entry'
require_relative '../dsu/models/entry_group'
require_relative '../dsu/support/fileable'

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
        if File.exist?(config_path)
          config_path = Support::Fileable.config_path
          old_config_hash = Psych.safe_load(File.read(config_path), [Symbol]).transform_keys(&:to_sym)
          config_hash = Dsu::Models::Configuration::DEFAULT_CONFIGURATION.merge(old_config_hash)
          config_hash[:entries_display_order] = config_hash[:entries_display_order].to_sym
          config_hash.delete('entries_file_name')
          config_hash.delete('entries_folder')
          config_hash[:version] = migration_version
          Models::Configuration.instance.load(config_hash: config_hash).save!
        else
          Models::Configuration.instance
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
