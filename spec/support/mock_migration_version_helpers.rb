# frozen_string_literal: true

# NOTE: This expects the "mock_and_cleanup_dirs" shared context
# to be included in the spec file where it is used.

module MockMigrationVersionHepers
  def mock_migration_version_for(version:)
    remove_mock_dsu_folder_and_configuration

    create_mock_dsu_folder_for(version)
    create_mock_dsu_configuration_for(version)
    create_migration_version_for_if(version)
  end

  def dsu_folders_and_file_contents_match?(expected:, actual:, known_deleted_files: [], known_added_files: [])
    expected_files = dsu_folder_contents(expected)
    actual_files = dsu_folder_contents(actual)

    puts "\ndsu_folder_contents(expected)->\n#{expected_files.join("\n")}"
    puts "\n\ndsu_folder_contents(actual)->\n#{actual_files.join("\n")}"
    puts "\n\nKnown deleted actual files->\n#{known_deleted_files.join("\n")}"
    puts "\n\nKnown added expeccted files->\n#{known_added_files.join("\n")}"

    expected_files -= known_deleted_files
    actual_files -= known_added_files

    return false unless expected_files == actual_files

    expected_files.each_with_index do |expected_file, index|
      next if File.directory?(File.join(expected, expected_file))

      return false unless display_no_match_if(
        expected_file: File.join(expected, expected_file),
        actual_file: File.join(actual, actual_files[index])
      )
    end

    true
  end

  private

  def display_no_match_if(expected_file:, actual_file:)
    files_match?(expected_file: expected_file, actual_file: actual_file).tap do |match|
      puts "\nExpected file -> #{expected_file}\nActual file -> #{actual_file}\nMatch? -> #{match}"
    end
  end

  def files_match?(expected_file:, actual_file:)
    json_files_match?(expected_file: expected_file, actual_file: actual_file)
  end

  # def files_match_extension_names?(files:, extension: 'json')
  #   files.all? { |file| File.extname(file) == 'json' }
  # end

  def json_files_match?(expected_file:, actual_file:)
    JSON.parse(File.read(expected_file)) == JSON.parse(File.read(actual_file))
  end

  def dsu_folder_contents(folder, exclude_files = [])
    exclude_files << '.DS_Store'
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
    FileUtils.cp(source_file, File.join(temp_folder, '.dsu'))
  end

  def create_migration_version_for_if(version)
    create(:migration_version, version: version) unless version.zero?
  end

  def remove_mock_dsu_folder_and_configuration
    FileUtils.rm_rf(File.join(temp_folder, 'dsu'))
    FileUtils.rm_rf(File.join(temp_folder, '.dsu'))
    Dir.glob(File.join(temp_folder, 'dsu-*-backup')).each do |backup_folder|
      FileUtils.rm_rf(backup_folder)
    end
  end
end
