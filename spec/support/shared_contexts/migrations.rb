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
      raise "source_folder must be defined and begin with #{gem_dir}"
    end
  end

  def ensure_safe_destination_folder!
    unless destination_folder.present? && destination_folder.start_with?(Dir.tmpdir, '/tmp')
      raise "destination_folder must be defined and begin with #{Dir.tmpdir}"
    end
  end

  before do
    ensure_safe_source_folder!
    ensure_safe_destination_folder!

    if with_migration_version_file
      # migration_version_path = Dsu::Migration::Service.migration_version_path
      # puts "Creating migration version file: #{migration_version_path} with version #{migration_version_file_version}..."
      # File.write(migration_version_path, Psych.dump({ migration_version: migration_version }))
    end

    puts 'Copy test config file to destination folder...'
    if with_config
      config_file_name = Dsu::Support::Fileable.config_file_name
      config_path = Dsu::Support::Fileable.config_path
      puts "From: #{File.join(source_folder, config_file_name)}" \
           "\n  To: #{config_path}"
      FileUtils.cp(File.join(source_folder, config_file_name), config_path)
    else
      puts 'Skipped (:with_config == false).'
    end

    puts 'Copy test color theme files to destination folder...'
    FileUtils.mkdir_p(Dsu::Support::Fileable.themes_folder)
    if with_themes
      Dir.glob("#{source_folder}/themes/*").each do |file_path|
        theme_path = File.join(Dsu::Support::Fileable.themes_folder, File.basename(file_path))
        puts "From: #{file_path}" \
             "\n  To: #{theme_path}"
        FileUtils.cp(file_path, theme_path)
      end
    else
      puts 'Skipped (:with_themes == false).'
    end

    puts 'Copy test entry files to destination folder...'
    FileUtils.mkdir_p(Dsu::Support::Fileable.entries_folder)
    if with_entries
      Dir.glob("#{source_folder}/entries/*").each do |file_path|
        entries_path = File.join(Dsu::Support::Fileable.entries_folder, File.basename(file_path))
        puts "From: #{file_path}" \
             "\n  To: #{entries_path}"
        FileUtils.cp(file_path, entries_path)
      end
    else
      puts 'Skipped (:with_entries == false).'
    end

    allow(Dsu::Migration::Service).to receive(:migration_version_folder).and_return(destination_folder)
    migration_version_file = Dsu::Support::Fileable::MIGRATION_VERSION_FILE_NAME
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
    unless temp_folder.present? && temp_folder.start_with?(Dir.tmpdir, '/tmp')
      raise "temp_folder must be defined and begin with #{Dir.tmpdir}"
    end

    File.join(temp_folder, 'dsu')
  end
  let(:with_config) { true }
  let(:with_entries) { true }
  let(:with_themes) { true }
  let(:with_migration_version_file) { false }
  let(:migration_version_file_version) { 0 }
end

RSpec.configure do |config|
  # config.include_context 'with migrations'
end
