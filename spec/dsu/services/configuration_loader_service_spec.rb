# frozen_string_literal: true

RSpec.describe Dsu::Services::ConfigurationLoaderService do
  subject(:configuration_loader_service) { described_class.new(default_options: default_options) }

  let(:default_options) { nil }
  let(:default_configuration) { Dsu::Support::Configuration::DEFAULT_DSU_OPTIONS }

  describe '#initialize' do
    context 'when the arguments are valid' do
      it_behaves_like 'no error is raised'
    end

    # No errors are expected because the options are not
    # considered until #call is invoked.
    context 'when the arguments are invalid' do
      let(:default_options) { 'invalid' }

      it_behaves_like 'no error is raised'
    end
  end

  describe '#call' do
    context 'when no default options are passed and the configuration file does not exist' do
      subject(:configuration_loader_service) { described_class.new }

      it 'returns the default configuration options' do
        expect(configuration_loader_service.call).to eq default_configuration
      end
    end

    context 'when default options are passed and the configuration file does not exist' do
      let(:default_options) do
        {
          'version' => 'some version',
          'entries_folder' => '/some/folder',
          'entries_file_name' => 'some file name'
        }
      end

      it 'returns the passed options' do
        expect(configuration_loader_service.call).to eq default_options
      end
    end

    context 'when no default options are passed and the configuration file does exist' do
      subject(:configuration_loader_service) { described_class.new }

      before do
        create_config_file!
      end

      after do
        delete_config_file!
      end

      it 'returns the configuration file options' do
        expect(configuration_loader_service.call).to eq default_configuration
      end
    end

    context 'when default options are passed and the configuration file does exist' do
      before do
        create_config_file!
      end

      after do
        delete_config_file!
      end

      let(:default_options) do
        Dsu::Support::Configuration::DEFAULT_DSU_OPTIONS.merge({
          'version' => 'changed version',
          'entries_file_name' => 'changed entries file name',
        })
      end

      it 'returns the default options merged with the configuration file options' do
        expect(configuration_loader_service.call).to eq default_options
      end
    end
  end
end
