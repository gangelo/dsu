# frozen_string_literal: true

require_relative '../dsu/migration/service'
require_relative '../dsu/models/color_theme'
require_relative '../dsu/models/configuration'
require_relative '../dsu/models/entry'
require_relative '../dsu/models/entry_group'
require_relative '../dsu/support/fileable'

module Dsu
  module Migrate
    class CopyColorThemeFiles < Migration::Service[1.0]
      def call
        unless migrate?
          raise "This migration file migration version (#{migration_version}) " \
                "is > the current migration version (#{current_migration_version})."
        end

        Models::ColorTheme.tap do |color_theme|
          color_theme.build_color_theme(theme_name: 'cherry', base_color: :red,
            description: 'As in bomb!').save!
          color_theme.build_color_theme(theme_name: 'cloudy', base_color: :light_black,
            description: 'Feeling melancholy?').save!
          color_theme.build_color_theme(theme_name: 'fozzy', base_color: :magenta,
            description: 'But not bear.').save!
          color_theme.build_color_theme(theme_name: 'lemon', base_color: :yellow,
            description: 'Citrus delight!').save!
          color_theme.build_color_theme(theme_name: 'matrix', base_color: :green,
            description: 'Hello Morpheus!').save!
        end

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
