# frozen_string_literal: true

# rubocop:disable RSpec/NestedGroups

# All this preprocessing does is make the old entries folder "unsafe" to manipulate
# by moving the entry group files to the '/tmp/dsu/entries' folder. The configuration
# file is also updated to point to the 'unsafe' entries folder so that the migration
# process knows where to find the entry group files.
def setup_unsafe_entries_folder(unsafe_entries_folder:)
  config_path = Dsu::Support::Fileable.config_path
  config_hash = read_configuration_version0!(config_path: config_path)
  entries_folder = unsafe_entries_folder
  FileUtils.mkdir_p(entries_folder)
  config_hash[:entries_folder] = entries_folder
  update_configuration_version0!(config_hash: config_hash, config_path: config_path)
  from_folder = Dsu::Support::Fileable.entries_folder
  move_entry_group_files(from_folder: from_folder, to_folder: entries_folder)
end

def move_entry_group_files(from_folder:, to_folder:)
  if File.basename(from_folder) == File.basename(to_folder)
    FileUtils.mv(Dir.glob("#{from_folder}/*"), to_folder)
  else
    FileUtils.mv(from_folder, to_folder)
  end
  config_path = Dsu::Support::Fileable.config_path
  config_hash = { entries_folder: File.join(destination_folder, File.basename(to_folder)) }
  update_configuration_version0!(config_hash: config_hash, config_path: config_path)
end

def rename_entry_group_files(entries_folder:, file_strftime: '%m-%d-%Y.json')
  puts "Renaming entry group files using format \"#{file_strftime}\"..."
  Dir.glob("#{entries_folder}/*").each do |file_path|
    time = Time.parse(File.basename(file_path, '.*'))
    new_file_path = File.join(entries_folder, time.strftime(file_strftime))
    puts "From: #{file_path}" \
         "\n  to: #{new_file_path}"
    FileUtils.mv(file_path, new_file_path)

    # We have to update the configuration to recognize the entries folder and new
    # file name format.
    config_path = Dsu::Support::Fileable.config_path
    config_hash = {
      entries_file_name: file_strftime,
      entries_folder: File.dirname(new_file_path)
    }
    update_configuration_version0!(config_hash: config_hash, config_path: config_path)
  end
end

RSpec.describe Dsu::Migrate::UpgradeToVersionTwoDotZeroDotZero do # rubocop:disable RSpec/FilePath
  subject(:migration) { described_class.new }

  include_context 'with migrations'

  shared_examples 'the migration version file is updated to the latest migration version' do
    it 'updates the migration file version' do
      subject.call
      expect(migration.current_migration_version).to eq(end_migration_version)
    end
  end

  shared_examples 'the color theme files are created' do
    it 'creates the default color theme files' do
      subject.call
      expected_color_theme_names = %w[default cherry cloudy fozzy lemon matrix]
      expect(Dsu::Models::ColorTheme.all.map(&:theme_name)).to match_array expected_color_theme_names
    end
  end

  shared_examples 'the entry group files exist in the right folder' do
    it 'creates the expected entry group files' do
      subject.call
      expected_entry_group_times = %w[2023-06-15 2023-06-16 2023-06-17]
      expect(Dsu::Models::EntryGroup.all&.map(&:time_yyyy_mm_dd)).to match_array(expected_entry_group_times)
    end
  end

  shared_examples 'the old entry group files are renamed and exist in the right folder' do
    it 'renames the old entry group files' do
      subject.call
      expected_entry_group_times = %w[06-15-2023.json.old 06-16-2023.json.old 06-17-2023.json.old]
      expect(expected_entry_group_times.all? do |old_file|
        File.exist?(File.join(Dsu::Support::Fileable.entries_folder, old_file))
      end).to be true
    end
  end

  shared_examples 'no entry group files are created' do
    it 'does not create any entry group files' do
      subject.call
      expect(Dsu::Models::EntryGroup.any?).to be false
    end
  end

  shared_examples 'the entry group files are updated' do
    it 'updates the entry group files' do # rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
      subject.call
      expected_entry_group_times.each do |time|
        entry_group_time = Time.parse(time)
        entry_group = Dsu::Models::EntryGroup.find(time: entry_group_time)
        expect(entry_group.version).to eq end_migration_version
        expect(entry_group.time_equal?(other_time: entry_group_time)).to be true
        expect(entry_group.entries.count).to eq 2
        formatted_entry_group_time = entry_group_time.strftime(Dsu::Support::TimeComparable::TIME_COMPARABLE_FORMAT_SPECIFIER)
        expect(entry_group.entries[0].description).to eq "#{formatted_entry_group_time} description 0"
        expect(entry_group.entries[1].description).to eq "#{formatted_entry_group_time} description 1"
      end
    end
  end

  describe '#call' do
    let(:start_migration_version) { 0 }
    let(:end_migration_version) { 20230613121411 } # rubocop:disable Style/NumericLiterals

    context 'when the configuration file does not exist' do
      before do
        File.delete(Dsu::Support::Fileable.config_path)
      end

      it_behaves_like 'the color theme files are created'
      it_behaves_like 'the migration version file is updated to the latest migration version'

      it 'creates a default configuration file' do
        migration.call
        expect(Dsu::Models::Configuration.exist?).to be(true)
      end
    end

    context 'when the configuration file exists' do
      before do
        File.write(Dsu::Support::Fileable.config_path, ConfigurationHelpers::CONFIGURATION_HASHES[start_migration_version.to_s].to_yaml)
      end

      let(:configuration) { Dsu::Models::Configuration.instance }

      it_behaves_like 'the color theme files are created'
      it_behaves_like 'the migration version file is updated to the latest migration version'

      it 'creates the configuration file and carries over the values from the old configuration file' do # rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
        migration.call
        expect(configuration.version).to eq(end_migration_version)
        expect(configuration.editor).to eq('vim')
        expect(configuration.entries_display_order).to eq(:asc)
        expect(configuration.carry_over_entries_to_today).to be(true)
        expect(configuration.include_all).to be(true)
        expect(configuration.theme_name).to eq('default')
      end
    end

    context 'when the migration version file does not exist' do
      let(:with_migration_version_file) { false }
      let(:expected_entry_group_times) { %w[2023-06-15 2023-06-16 2023-06-17] }

      it_behaves_like 'the color theme files are created'
      it_behaves_like 'the entry group files exist in the right folder'
      it_behaves_like 'the entry group files are updated'
      it_behaves_like 'the migration version file is updated to the latest migration version'
    end

    context 'when the migration version file exists' do
      context 'when the migration version file version is greater than the migration version' do
        subject(:migration) { described_class.new.call }

        let(:migration_version_file_version) { end_migration_version }
        let(:expected_error) { /is not < the current migration version/ }

        it_behaves_like 'an error is raised'
      end

      context 'when the migration version file version is less than the migration version' do
        subject(:migration) { described_class.new.call }

        let(:migration_version_file_version) { 0 }

        it_behaves_like 'no error is raised'
      end
    end

    context 'when there are entry group files' do
      let(:expected_entry_group_times) { %w[2023-06-15 2023-06-16 2023-06-17] }

      context 'when the entry group files need to be moved to the new entries folder' do
        context 'when the old entries folder is not "safe" to manipulate' do # rubocop:disable RSpec/MultipleMemoizedHelpers
          before do
            setup_unsafe_entries_folder(unsafe_entries_folder: unsafe_entries_folder)
          end

          let(:destination_folder) { '/tmp/dsu' }
          let(:unsafe_entries_folder) { File.join(destination_folder, 'entries') }
          let(:expected_console_output) do
            /.*Old entries folder "#{unsafe_entries_folder}".*This folder along with its old entry files may be deleted at your discretion.*/m
          end

          it 'displays a message to the user that the old entries folder and entry files are safe to delete' do
            expect { migration.call }.to output(expected_console_output).to_stdout
          end

          it_behaves_like 'the entry group files exist in the right folder'
          it_behaves_like 'the entry group files are updated'
          it_behaves_like 'the migration version file is updated to the latest migration version'
        end

        context 'when the old entries folder is "safe" to manipulate' do
          before do
            from_folder = File.join(destination_folder, 'entries')
            to_folder = File.join(destination_folder, 'old_entries')
            move_entry_group_files(from_folder: from_folder, to_folder: to_folder)
          end

          it_behaves_like 'the entry group files exist in the right folder'
          it_behaves_like 'the entry group files are updated'
          it_behaves_like 'the migration version file is updated to the latest migration version'
        end
      end

      context 'when the entry group files DO NOT need to be moved to the new entries folder' do
        it_behaves_like 'the entry group files exist in the right folder'
        it_behaves_like 'the entry group files are updated'
        it_behaves_like 'the migration version file is updated to the latest migration version'
      end

      context 'when the entry group files need to be renamed' do
        before do
          entries_folder = File.join(destination_folder, File.basename(Dsu::Support::Fileable.entries_folder))
          rename_entry_group_files(entries_folder: entries_folder)
        end

        it_behaves_like 'the entry group files exist in the right folder'
        it_behaves_like 'the old entry group files are renamed and exist in the right folder'
        it_behaves_like 'the entry group files are updated'
        it_behaves_like 'the migration version file is updated to the latest migration version'
      end
    end

    context 'when there are no entry group files' do
      let(:with_entries) { false }

      it_behaves_like 'no entry group files are created'
      it_behaves_like 'the migration version file is updated to the latest migration version'
    end
  end
end
# rubocop:enable RSpec/NestedGroups
