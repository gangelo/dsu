# frozen_string_literal: true

RSpec.describe Dsu::Support::Configuration do
  subject(:config) do
    Class.new do
      include Dsu::Support::Configuration
    end.new
  end

  describe 'constants' do
    describe 'DEFAULT_DSU_OPTIONS' do
      let(:expected_keys) { %w[editor entries_display_order entries_folder entries_file_name carry_over_entries_to_today] }

      it 'defines the right keys' do
        expect(described_class::DEFAULT_DSU_OPTIONS.keys).to match_array expected_keys
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
        config.create_config_file!
      end

      after do
        config.delete_config_file!
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
      before do
        config.delete_config_file!
        config.create_config_file!
      end

      after do
        config.delete_config_file!
      end

      it 'creates the config file' do
        expect(config.config_file?).to be true
      end
    end

    context 'when the config file destination folder does not exist' do
      subject(:config) { config_with_bad_config_file }

      specify 'makes sure the config file does not exist' do
        expect(config.config_file?).to be false
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
      subject(:config) { config_with_bad_config_file }

      specify 'makes sure the config file does not exist' do
        expect(config.config_file?).to be false
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

      after do
        config.delete_config_file!
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
      specify 'makes sure the config file does not exist' do
        expect(config.config_file?).to be false
      end

      it 'prints the config file' do
        expect { config.print_config_file }.to output(/does not exist/).to_stdout
      end
    end
  end
end
