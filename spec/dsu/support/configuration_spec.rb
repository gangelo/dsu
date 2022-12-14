# frozen_string_literal: true

RSpec.describe Dsu::Support::Configuration do
  subject(:config) do
    Class.new do
      include Dsu::Support::Configuration
    end.new
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

  describe '#create_config_file!' do
    context 'when the config file does not exist' do
      context 'when creating the config file it should not exist' do
        it 'does not exist' do
          expect(config.config_file?).to be false
        end
      end

      it 'creates the config file' do
        config.create_config_file!
        expect(config.config_file?).to be true
      end
    end

    context 'when the config file destination folder does not exist' do
      before do
        folder = File.dirname(config.config_file)
        bad_config_file = config.config_file.gsub(folder, Random.uuid)
        allow(config).to receive(:config_file).and_return(bad_config_file)
      end

      context 'when creating the config file it should not exist' do
        it 'does not exist' do
          expect(config.config_file?).to be false
        end
      end

      it 'displays a message to the console' do
        expected_output = /Destination folder\x20.+\x20does not exist/
        expect { config.create_config_file! }.to output(expected_output).to_stdout
      end
    end

    context 'when the config file already exists' do
      before do
        config.create_config_file!
      end

      context 'when creating the config file it should exist' do
        it 'exists' do
          expect(config.config_file?).to be true
        end
      end

      it 'displays a message to the console' do
        expect { config.create_config_file! }.to output(/already exists/).to_stdout
      end
    end
  end

  describe '#delete_config_file!' do
    context 'when the config file exists' do
      before do
        config.create_config_file!
      end

      context 'when deleting the config file it should exist' do
        it 'exists' do
          expect(config.config_file?).to be true
        end
      end

      it 'deletes the config file' do
        config.delete_config_file!
        expect(config.config_file?).to be false
      end
    end

    context 'when the config file does not exist' do
      before do
        folder = File.dirname(config.config_file)
        bad_config_file = config.config_file.gsub(folder, Random.uuid)
        allow(config).to receive(:config_file).and_return(bad_config_file)
      end

      context 'when deleting the config file it should not exist' do
        it 'does not exist' do
          expect(config.config_file?).to be false
        end
      end

      it 'displays a message to the console' do
        expected_output = /Configuration file\x20.+\x20does not exist/
        expect { config.delete_config_file! }.to output(expected_output).to_stdout
      end
    end
  end

  describe '#print_config_file' do
    context 'when the configuration file exists' do
      before do
        config.create_config_file!
      end

      context 'when setting up this test the config file should exist' do
        it 'exists' do
          expect(config.config_file?).to be true
        end
      end

      it 'prints the config file' do
        expect { config.print_config_file }.to output(/Config file/).to_stdout
      end
    end

    context 'when the configuration file does not exists' do
      context 'when setting up this test the config file should not exist' do
        it 'does not exist' do
          expect(config.config_file?).to be false
        end
      end

      it 'prints the config file' do
        expect { config.print_config_file }.to output(/does not exist/).to_stdout
      end
    end
  end
end
