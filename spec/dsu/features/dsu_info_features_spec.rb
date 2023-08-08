# frozen_string_literal: true

RSpec.describe 'Dsu info features', type: :feature do
  subject(:cli) { Dsu::CLI.start(args) }

  context "when 'dsu help info' is called" do
    let(:args) { %w[help info] }

    it 'displays help' do
      expect { cli }.to output(/Usage:.*rspec info/m).to_stdout
    end
  end

  context "when 'dsu info' is called" do
    subject(:cli_output) do
      Dsu::Services::StdoutRedirectorService.call do
        cli
      end
    end

    let(:args) { %w[info] }
    let(:fileable) { Dsu::Support::Fileable }

    it 'displays the configuration version' do
      configuration = build(:configuration)
      expect(cli_output).to include "Configuration version: #{configuration.version}"
    end

    it 'displays the entry group version' do
      entry_group = build(:entry_group)
      expect(cli_output).to include "Entry group version: #{entry_group.version}"
    end

    it 'displays the color theme version' do
      color_theme = build(:color_theme)
      expect(cli_output).to include "Color theme version: #{color_theme.version}"
    end

    it 'displays the root folder' do
      expect(cli_output).to include "Root folder: #{fileable.root_folder}"
    end

    it 'displays the entries folder' do
      expect(cli_output).to include "Entries folder: #{fileable.entries_folder}"
    end

    it 'displays the themes folder' do
      expect(cli_output).to include "Themes folder: #{fileable.themes_folder}"
    end

    it 'displays the migrate folder' do
      expect(cli_output).to include "Migrate folder: #{fileable.migrate_folder}"
    end

    it 'displays the gem folder' do
      expect(cli_output).to include "Gem folder: #{fileable.gem_dir}"
    end

    it 'displays the temp folder' do
      expect(cli_output).to include "Temp folder: #{fileable.temp_folder}"
    end

    it 'displays the config path' do
      expect(cli_output).to include "Config path: #{fileable.config_path}"
    end

    it 'displays the migration version folder' do
      expect(cli_output).to include "Migration version folder: #{fileable.migration_version_folder}"
    end

    it 'displays the migration file path' do
      expect(cli_output).to include "Migration file path: #{fileable.migration_version_path}"
    end
  end
end
