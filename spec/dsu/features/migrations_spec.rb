# froen_string_literal: true

RSpec.describe 'Migrations' do
  subject(:migrations) { nil }

  shared_context 'with migrations'

  before do
    puts "Test data to copy from: #{source_folder}"
    puts "Folder to copy test data to: #{destination_folder}"
    FileUtils.cp_r("#{source_folder}/.", destination_folder)

    allow(Dsu::Migration::Service).to receive(:migration_version_folder).and_return(destination_folder)
  end

  after do
    files_and_folders_to_delete = "#{destination_folder}/."
    puts "Deleting test data from: #{files_and_folders_to_delete}"
    FileUtils.rm_rf(files_and_folders_to_delete)
  end

  let(:gem_dir) { Gem.loaded_specs['dsu'].gem_dir }

  let(:source_folder) do
    source_folder = File.join(gem_dir, 'spec/dsu/test_data')
    File.join(source_folder, start_migration_version.to_s)
  end

  let(:destination_folder) do
    File.join(gem_dir, 'spec/dsu/test_data/dsu')
  end

  describe 'migrating from version 0 to version 20230613121411' do
    let(:start_migration_version) { 0 }
    let(:end_migration_version) { 20230613121411 }

    before do
      Dsu::Migration::Service[1.0].run_migrations!
    end

    it 'updates the migration file version' do
      expect(Dsu::Migration::Service[1.0].current_migration_version).to eq(end_migration_version)
    end

    it 'updates the configuration to the new version'

    it 'updates the entries to the new version'
  end
end
