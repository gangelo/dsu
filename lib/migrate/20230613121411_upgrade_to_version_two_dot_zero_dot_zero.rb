# frozen_string_literal: true

require_relative '../dsu/migration/service'
require_relative '../dsu/models/color_theme'
require_relative '../dsu/models/configuration'
require_relative '../dsu/models/entry'
require_relative '../dsu/models/entry_group'

module Dsu
  module Migrate
    class UpgradeToVersionTwoDotZeroDotZero < Migration::Service[1.0]
      def call
        unless migrate?
          raise "This migration file migration version (#{migration_version}) " \
                "is > the current migration version (#{current_migration_version})."
        end

        update_color_themes!
        update_configuration!
        binding.pry
        unless old_entries_folder && (old_entries_folder == entries_folder)
          Dir.glob("#{old_entries_folder}/*").each do |file|
            FileUtils.mv(file, entries_folder)
          end
        end
        update_entry_groups!

        super
      rescue StandardError => e
        puts "Error running migration #{File.basename(__FILE__)}: #{e.message}"
        raise
      end

      private

      attr_reader :old_entries_folder, :old_entries_file_name

      def migration_version
        File.basename(__FILE__).match(Migration::MIGRATION_VERSION_REGEX).try(:[], 0)&.to_i
      end

      def read_old_configuration
        config_path = Support::Fileable.config_path
        Psych.safe_load(File.read(config_path), [Symbol]).transform_keys(&:to_sym)
      end

      def update_color_themes!
        Models::ColorTheme.default.save!

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
      end

      def update_configuration!
        if File.exist?(config_path)
          old_config_hash = Psych.safe_load(File.read(config_path), [Symbol]).transform_keys(&:to_sym)
          config_hash = Dsu::Models::Configuration::DEFAULT_CONFIGURATION.merge(old_config_hash)
          config_hash[:entries_display_order] = config_hash[:entries_display_order].to_sym
          config_hash.delete(:entries_file_name)

          # Save the old entries folder so we can move the entries file to the new
          # entries folder if necessary.
          @old_entries_folder = old_config_hash[:entries_folder]
          @old_entries_file_name = old_config_hash[:entries_file_name]

          config_hash.delete(:entries_folder)
          config_hash[:version] = migration_version
          Models::Configuration.instance.load(config_hash: config_hash).save!
        else
          Models::Configuration.instance.save!
        end
      end

      def update_entry_groups!
        Dir.glob("#{entries_folder}/*").each do |entry_group_file|
          binding.pry
          entry_group_hash = JSON.parse(File.read(entry_group_file))
          time = Time.parse(entry_group_hash[:time])
          Model::EntryGroup.new(time: time).tap do |entry_group|
            entry_group_hash[:entries].each do |entry_hash|
              entry_group.entries << Model::Entry.new(description: entry_hash[:description])
            end
            delete_old_entry_group_file_if(time: time)
          end.save!
        end
      end

      def delete_old_entry_group_file_if(time:)
        old_entries_path = entries_path(time: time, file_name_format: :old_entries_file_name)
        return if entries_path(time: time) == old_entries_path
        return unless File.exist?(old_entries_path)

        binding.pry
        #File.delete(old_entries_path)
      end
    end
  end
end
