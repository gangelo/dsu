# frozen_string_literal: true

module MigrationServiceHelpers
  def migration_service_info_for(migration_file:, migrate_folder:)
    file_path = File.join(migrate_folder, migration_file)
    file_name = File.basename(file_path)
    migration_class = file_name.match(/\A\d+_(.+)\.rb\z/)[1].camelize
    {
      migration_class: "Dsu::Migrate::#{migration_class}",
      path: file_path,
      require_file: file_path.sub(/\.[^.]+\z/, ''),
      version: file_name.match(Dsu::Migration::MIGRATION_VERSION_REGEX).try(:[], 0)&.to_i
    }
  end
end
