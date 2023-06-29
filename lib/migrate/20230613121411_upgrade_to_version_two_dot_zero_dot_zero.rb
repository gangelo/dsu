# frozen_string_literal: true

require_relative '../dsu/migration/service'
require_relative '../dsu/models/color_theme'
require_relative '../dsu/models/configuration'
require_relative '../dsu/models/entry'
require_relative '../dsu/models/entry_group'

module Dsu
  module Migrate
    class UpgradeToVersionTwoDotZeroDotZero < Migration::Service[1.0]
      OLD_FILENAME_EXT = '.old'

      def call
        unless migrate?
          raise "This migration file migration version (#{migration_version}) " \
                "is not < the current migration version (#{current_migration_version})."
        end

        update_color_themes!
        update_configuration!
        update_entry_groups!
        display_entries_folder_changed_message_if
        display_entries_file_name_changed_message_if

        super
      rescue StandardError => e
        puts "Error running migration #{File.basename(__FILE__)}: #{e.message}"
        raise
      end

      private

      attr_reader :old_entries_folder, :old_entries_file_name

      def root_folder
        Support::Fileable.root_folder
      end

      def config_path
        Support::Fileable.config_path
      end

      def entries_folder
        Support::Fileable.entries_folder
      end

      def entries_path(time:, file_name_format: nil)
        Support::Fileable.entries_path(time: time, file_name_format: file_name_format)
      end

      def migration_version
        @migration_version ||= File.basename(__FILE__).match(Migration::MIGRATION_VERSION_REGEX).try(:[], 0)&.to_i
      end

      def old_entries_file_name?
        old_entries_file_name.present?
      end

      def entries_file_name_changed?
        return unless old_entries_file_name?

        old_entries_file_name != Support::Fileable::ENTRIES_FILE_NAME_FORMAT
      end

      def entries_folder_changed?
        return unless old_entries_folder?

        old_entries_folder != entries_folder
      end

      def old_entries_folder?
        old_entries_folder.present?
      end

      def safe_old_entries_folder?
        return if old_entries_folder.nil?
        return unless old_entries_folder.start_with?(root_folder)
        return unless Dir.exist?(old_entries_folder)

        true
      end

      def read_old_configuration
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
        FileUtils.mkdir_p(Dsu::Support::Fileable.entries_folder)

        if File.exist?(config_path)
          old_config_hash = read_old_configuration
          config_hash = Models::Configuration::DEFAULT_CONFIGURATION.merge(old_config_hash)
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
        copy_entry_groups_if
        Dir.glob("#{entries_folder}/*").each do |entry_group_file|
          entry_group_hash = JSON.parse(File.read(entry_group_file)).with_indifferent_access
          next if entry_group_hash[:version] == migration_version

          time = Time.parse(entry_group_hash[:time])
          Models::EntryGroup.new(time: time, version: migration_version).tap do |entry_group|
            entry_group_hash[:entries].each do |entry_hash|
              entry_group.entries << Models::Entry.new(description: entry_hash[:description])
            end
            rename_old_entry_group_file_if(time: time)
          end.save!
        end
      end

      def copy_entry_groups_if
        return unless entries_folder_changed?

        Dir.glob("#{old_entries_folder}/*").each do |file_path|
          new_file_path = File.join(entries_folder, File.basename(file_path))
          puts "Copying: #{file_path}" \
               "\n     to: #{new_file_path}..."
          FileUtils.cp(file_path, new_file_path)
        end
      end

      def rename_old_entry_group_file_if(time:)
        return unless old_entries_folder?
        return unless entries_folder_changed? || entries_file_name_changed?

        old_entries_path = entries_path(time: time, file_name_format: old_entries_file_name)
        return unless entries_file_name_changed? && File.exist?(old_entries_path)

        renamed_old_entries_file_name_format = "#{old_entries_file_name}#{OLD_FILENAME_EXT}"
        renamed_old_entries_path = entries_path(time: time, file_name_format: renamed_old_entries_file_name_format)
        puts "Renaming #{old_entries_path} to #{renamed_old_entries_path}..."
        File.rename(old_entries_path, renamed_old_entries_path)
      end

      def display_entries_folder_changed_message_if
        return unless entries_folder_changed?

        puts "Old entries folder \"#{old_entries_folder}\" contains old entry files " \
             'that were copied and updated...'
        puts 'This folder along with its old entry files may be deleted at your discretion.'
      end

      def display_entries_file_name_changed_message_if
        return unless entries_file_name_changed?

        new_entries_file_name = Support::Fileable::ENTRIES_FILE_NAME_FORMAT
        old_entries_file_name_moved_to = File.join(entries_folder, "#{old_entries_file_name}#{OLD_FILENAME_EXT}")
        puts 'Entry group file name format has changed...' \
             "\n  from \"#{old_entries_file_name}\"" \
             "\n    to \"#{new_entries_file_name}\"" \
             "\nThe OLD files were moved and renamed to \"#{old_entries_file_name_moved_to}\" " \
             'and may be deleted at your discretion.'
      end
    end
  end
end
