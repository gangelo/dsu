# frozen_string_literal: true

RSpec.describe Dsu::Migration::Service do
  subject(:service) { described_class.new(options: options) }

  shared_examples 'the migration is successful' do
    it 'backs up the old config file' do
      expect(File.exist?(File.join(backup_folder, Dsu::Support::Fileable.config_file_name))).to be true
    end

    it 'backs up the old entry files' do
      entries_folder = File.basename(Dsu::Support::Fileable.entries_folder)
      expect(File.exist?(File.join(backup_folder, entries_folder, Dsu::Support::Fileable.entries_file_name(time: time)))).to be true
    end

    it 'backs up the old theme files' do
      themes_folder = File.basename(Dsu::Support::Fileable.themes_folder)
      expect(File.exist?(File.join(backup_folder, themes_folder, Dsu::Support::Fileable.theme_file_name(theme_name: theme_name)))).to be true
    end

    it 'creates the new config file' do
      expect(File.exist?(Dsu::Support::Fileable.config_path)).to be true
    end

    it 'copies the new theme files' do
      theme_names = %w[cherry default lemon matrix whiteout]
      themes_exist = theme_names.all? { |theme_name| File.exist?(Dsu::Support::Fileable.themes_path(theme_name: theme_name)) }
      expect(themes_exist).to be true
    end

    it 'creates an initial entry group' do
      expect(File.exist?(Dsu::Support::Fileable.entries_path(time: time))).to be true
    end
  end

  let(:options) { {} }

  describe 'class methods' do
    describe '.run_migrations?' do
      context 'when the migration version is current' do
        before do
          create(:migration_version, :with_current_version)
        end

        it 'returns false' do
          expect(described_class.run_migrations?).to be(false)
        end
      end

      context 'when the migration version less than the current version' do
        before do
          create(:migration_version, version: Dsu::Migration::VERSION - 1)
        end

        it 'returns true' do
          expect(described_class.run_migrations?).to be(true)
        end
      end

      context 'when the migration version greater than the current version' do
        before do
          create(:migration_version, version: Dsu::Migration::VERSION + 1)
        end

        it 'returns false' do
          expect(described_class.run_migrations?).to be(false)
        end
      end
    end
  end

  context 'when migrations should not be run' do
    subject(:service) { build(:migration_service) }

    before do
      create(:migration_version, :with_current_version)
    end

    specify 'the migration version file exists' do
      migration_version = create(:migration_version, :with_current_version)
      expect(migration_version).to exist
    end

    it 'does not run migrations' do
      expect { service.call }.to output(/Nothing to do/).to_stdout
    end
  end

  context 'when migrations should be run' do
    subject(:service) { build(:migration_service) }

    before do
      FileUtils.touch(Dsu::Support::Fileable.config_path)
      FileUtils.touch(Dsu::Support::Fileable.entries_path(time: time))
      FileUtils.touch(Dsu::Support::Fileable.themes_path(theme_name: theme_name))
    end

    let(:time) { Time.now.in_time_zone }
    let(:theme_name) { 'old_theme' }
    let(:backup_folder) { Dsu::Support::Fileable.backup_folder(version: 0) }

    context 'when the migration file exists' do
      before do
        service.call
      end

      specify 'the migration version file exists' do
        migration_version = build(:migration_version, version: 0)
        expect(migration_version).to exist
      end

      it_behaves_like 'the migration is successful'
    end

    context 'when the migration file does not exist' do
      before do
        service.call
      end

      specify 'the migration version file does not exist' do
        migration_version = build(:migration_version)
        migration_version.delete
        expect(migration_version).not_to exist
      end

      it_behaves_like 'the migration is successful'
    end
  end
end
