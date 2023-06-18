# frozen_string_literal: true

RSpec.shared_context 'with migrations' do
  include_context 'with dirs'

  before do
    # TODO: require each migration file.
    # TODO: for each migration file: load each migration file and mock the migration_folder
    # e.g. allow(Dsu::Migration::MigratorService).to receive(:migrate_folder).and_return(test_migrations_folder)
  end

  let(:migrate_folder) { FileUtils.mkdir_p(File.join(tmp_folder, 'migrate')).first }
  let(:test_migrations_folder) { FileUtils.mkdir_p(File.join(tmp_folder, 'test_migrations')).first }

  let(:dsu_migration_service_class) do
    Dsu::Migration::Service[Dsu::Migration::Service::MIGRATION_SERVICE_VERSION]
  end
  let(:dsu_migration_service) do
    dsu_migration_service_class.new
  end
  let(:dsu_service_migrate_folder) { Dsu::Migrate::Service.migrate_folder }
  let(:dsu_migrations) do
    dsu_migration_service_class.all_migration_files_info
  end
end

RSpec.configure do |config|
  # config.include_context 'with migrations'
end
