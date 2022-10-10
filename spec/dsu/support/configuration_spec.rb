# frozen_string_literal: true

RSpec.describe Dsu::Support::Configuration do
  subject(:config) do
    class Klass
      include Dsu::Support::Configuration
    end
    Klass.new
  end

  before do
    stub_entries_version
  end

  after do
    File.delete(config.config_file) if config.config_file?
  end

  let(:stub_dir_home) do
    allow(Dir).to receive(:home).and_return(File.join(Dir.tmpdir, 'dsu/test_folders').to_s)
  end

  describe 'constants' do
    describe 'DEFAULT_DSU_OPTIONS' do
      let(:expected_options) do
        {
          version: Dsu::Support::EntriesVersion::ENTRIES_VERSION,
          entries_folder: "#{Dsu::Support::FolderLocations.root_folder}/dsu/entries",
          entries_file_name: '%Y-%m-%d.json'
        }
      end
      let(:expected_keys) { %w[version entries_folder entries_file_name] }

      it 'defines the right values' do
        expect(described_class::DEFAULT_DSU_OPTIONS.keys).to match expected_keys
      end
    end
  end

  describe '#config_file' do
    it 'returns the correct config file name' do
      expect(config.config_file).to eq File.join(Dir.home, described_class::CONFIG_FILENAME)
    end
  end

  describe '#config_file?' do
    context 'when the config file exists' do
      before do
        config_file = config.config_file
        directory = File.dirname config_file
        FileUtils.mkdir_p(directory) unless File.directory?(directory)
        FileUtils.touch config_file
      end

      it 'returns true' do
        expect(config.config_file?).to be true
      end
    end

    context 'when the config file does not exist' do
      it 'returns false' do
        expect(config.config_file?).to be false
      end
    end
  end

  describe '.create_config_file!' do
    context 'make sure the config file does not exist' do
      it 'does not exist' do
        expect(config.config_file?).to be false
      end
    end

    it 'creates the config file' do
      config.create_config_file!
      expect(config.config_file?).to be true
    end
  end
end
