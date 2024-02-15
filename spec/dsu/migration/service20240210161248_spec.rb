# frozen_string_literal: true

RSpec.describe Dsu::Migration::Service20240210161248, type: :migration do
  subject(:service) { described_class.new(options: options) }

  before do
    create(:migration_version, version: migration_version, options: options)
  end

  let(:options) { {} }
  let(:migration_version) { 20230613121411 } # rubocop:disable Style/NumericLiterals

  describe '#initialize' do
    let(:migration_version) { 0 }

    it_behaves_like 'no error is raised'
  end

  describe '#migrate_if!' do
    subject(:service_migrate_if) { service.migrate_if! }

    context 'when the migration version is not 20230613121411' do
      before do
        mock_migration_version_for(version: migration_version)
        service_migrate_if
      end

      let(:migration_version) { 0 }
      let(:expected) { File.join('spec', 'fixtures', 'folders', migration_version.to_s) }
      let(:actual) { Dsu::Support::Fileable.dsu_folder }

      it 'does not make any changes to the dsu folder structure or configuration file' do
        expect(dsu_folders_match?(expected: expected, actual: actual)).to be(true)
      end
    end

    context 'when the migration version is 20230613121411' do
      before do
        mock_migration_version_for(version: migration_version)
        service_migrate_if
      end

      shared_examples 'the migration was run in pretend mode' do
        let(:expected) { File.join('spec', 'fixtures', 'folders', migration_version.to_s) }
        let(:actual) { Dsu::Support::Fileable.dsu_folder }

        it 'does not make any changes to the dsu folder structure or configuration file' do
          expect(dsu_folders_match?(expected: expected, actual: actual)).to be(true)
        end
      end

      context 'when the pretend option is implicitly set to true (not provided)' do
        it_behaves_like 'the migration was run in pretend mode'
      end

      context 'when the pretend option is explicitly set to true' do
        let(:options) { { pretend: true } }

        it_behaves_like 'the migration was run in pretend mode'
      end

      context 'when the pretend option is set to false' do
        let(:options) { { pretend: false } }
        let(:expected) { File.join('spec', 'fixtures', 'folders', 20240210161248.to_s) } # rubocop:disable Style/NumericLiterals
        let(:actual) { Dsu::Support::Fileable.dsu_folder }

        it 'migrates the dsu folder structure and configuration file' do
          expect(dsu_folders_match?(expected: expected, actual: actual)).to be(true)
        end

        it 'sets all the entry group versions to the correct migration version' do
          all_entry_groups = Dsu::Models::EntryGroup.all
          expect(all_entry_groups.all? do |entry_group|
            entry_group.version == 20240210161248 # rubocop:disable Style/NumericLiterals
          end).to be(true)
        end

        it 'sets all the color theme versions to the correct migration version' do
          all_color_themes = Dsu::Models::ColorTheme.all
          expect(all_color_themes.all? do |color_theme|
            color_theme.version == 20240210161248 # rubocop:disable Style/NumericLiterals
          end).to be(true)
        end

        it 'sets the configuration file version to the correct migration version' do
          expect(Dsu::Models::Configuration.new.version).to eq(20240210161248) # rubocop:disable Style/NumericLiterals
        end

        it 'sets the migration version file version to the correct migration version' do
          expect(Dsu::Models::MigrationVersion.new.version).to eq(20240210161248) # rubocop:disable Style/NumericLiterals
        end

        it 'copies the christmas color theme' do
          expect(Dsu::Models::ColorTheme.new(theme_name: 'christmas').exist?).to be(true)
        end

        it 'copies the light color theme' do
          expect(Dsu::Models::ColorTheme.new(theme_name: 'light').exist?).to be(true)
        end
      end
    end
  end
end
