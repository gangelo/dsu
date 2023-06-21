# frozen_string_literal: true

RSpec.shared_context 'with migrations' do
  include_context 'when dir mock and cleanup is needed'

  def ensure_safe_gem_dir!
    unless gem_dir.present? && gem_dir.start_with?(Gem.loaded_specs['dsu'].gem_dir)
      raise "gem_dir must be defined and begin with #{gem_dir.start_with?(Gem.loaded_specs['dsu'].gem_dir)}"
    end
  end

  def ensure_safe_source_folder!
    unless source_folder.present? && source_folder.start_with?(gem_dir)
      raise "source_folder must be defined and begin with #{source_folder.start_with?(gem_dir)}"
    end
  end

  def ensure_safe_destination_folder!
    unless destination_folder.present? && destination_folder.start_with?(Dir.tmpdir)
      raise "destination_folder must be defined and begin with #{destination_folder.start_with?(Dir.tmpdir)}"
    end
  end

  before do
    ensure_safe_source_folder!
    ensure_safe_destination_folder!

    puts "Copying test data from: #{source_folder}..."
    puts "Copying test data to: #{destination_folder}..."
    FileUtils.cp_r("#{source_folder}/.", destination_folder)

    allow(Dsu::Migration::Service).to receive(:migration_version_folder).and_return(destination_folder)
    migration_version_file = Dsu::Migration::MIGRATION_VERSION_FILE_NAME
    allow(Dsu::Migration::Service).to receive(:migration_version_path).and_return(File.join(destination_folder, migration_version_file))
  end

  after do
    ensure_safe_destination_folder!

    files_and_folders_to_delete = "#{destination_folder}/."
    puts "Deleting test data from: #{files_and_folders_to_delete}"
    FileUtils.rm_rf(files_and_folders_to_delete)
  end

  let(:gem_dir) { Gem.loaded_specs['dsu'].gem_dir }
  let(:source_folder) do
    ensure_safe_gem_dir!

    source_folder = File.join(gem_dir, 'spec/dsu/test_data')
    File.join(source_folder, start_migration_version.to_s)
  end
  let(:destination_folder) do
    unless temp_folder.present? && temp_folder.start_with?(Dir.tmpdir)
      raise "temp_folder must be defined and begin with #{Dir.tmpdir}"
    end

    File.join(temp_folder, end_migration_version.to_s)
  end

  # let(:start_migration_version) do
  #   raise 'start_migration_version must be defined in the context of the spec'
  # end
  # let(:end_migration_version) do
  #   raise 'end_migration_version must be defined in the context of the spec'
  # end

  # it 'defines safe and correct source_folder variable for testing' do
  #   expect { ensure_safe_source_folder! }.not_to raise_error
  # end

  # it 'defines safe and correct destination_folder variable for testing' do
  #   expect { ensure_safe_destination_folder! }.not_to raise_error
  # end

  # it 'defines safe and correct gem_dir variable for testing' do
  #   expect { ensure_safe_gem_dir! }.not_to raise_error
  # end
end

RSpec.configure do |config|
  # config.include_context 'with migrations'
end
