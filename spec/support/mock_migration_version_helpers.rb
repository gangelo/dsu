# frozen_string_literal: true

# NOTE: This expects the "mock_and_cleanup_dirs" shared context
# to be included in the spec file where it is used.

module MockMigrationVersionHepers
  def mock_migration_version_for(version:)
    remove_mock_dsu_folder_and_configuration migration_version

    create_mock_dsu_folder_for(version)
    create_mock_dsu_configuration_for(version)
    create_migration_version_for_if(version)
  end

  def dsu_folders_match?(expected:, actual:)
    #dsu_folder_contents(expected) == dsu_folder_contents(actual)
    dsu_folder_contents_match?(expected: expected, actual: actual)
  end

  def dsu_folder_contents_match?(expected:, actual:)
    return false unless dsu_folder_contents(expected) == dsu_folder_contents(actual)

    expected_files = dsu_folder_contents(expected)
    actual_files = dsu_folder_contents(actual)

    expected_files.each_with_index do |expected_file, index|
      next if File.directory?(File.join(expected, expected_file))

      match = files_match?(expected_file: File.join(expected, expected_file),
        actual_file: File.join(actual, actual_files[index]))
      return false unless match
    end

    true
  end

  private

  def files_match?(expected_file:, actual_file:)
    File.read(expected_file).chomp == File.read(actual_file).chomp
  end

  def dsu_folder_contents(folder, exclude_files = ['.DS_Store'])
    root_path = Pathname.new(folder)
    contents = []

    root_path.find do |path|
      # Skip the root folder itself and any files/directories that should be excluded
      next if path == root_path || exclude_files.include?(path.basename.to_s)

      # Calculate the relative path from the root folder to the current path
      relative_path = path.relative_path_from(root_path).to_s

      # Add the relative path to the contents array
      contents << relative_path
    end

    contents.sort
  end

  def create_mock_dsu_folder_for(migration_version)
    File.join('spec', 'fixtures', 'folders', migration_version.to_s).tap do |source_folder|
      destination_folder = File.join(temp_folder, 'dsu')
      FileUtils.mkdir_p(destination_folder)
      FileUtils.cp_r(File.join(source_folder, '.'), destination_folder)
    end
  end

  def create_mock_dsu_configuration_for(migration_version)
    ext = migration_version.zero? ? 'yaml' : 'json'
    source_file = File.join('spec', 'fixtures', 'files', 'configurations', "#{migration_version}.#{ext}")
    FileUtils.cp(source_file, temp_folder)
  end

  def create_migration_version_for_if(version)
    create(:migration_version, version: version) unless version.zero?
  end

  def remove_mock_dsu_folder_and_configuration(migration_version)
    FileUtils.rm_rf(File.join(temp_folder, 'dsu'))
    FileUtils.rm_rf(File.join(temp_folder, '.dsu'))
    FileUtils.rm_rf(File.join(temp_folder, "dsu-#{migration_version}-backup"))
  end
end
