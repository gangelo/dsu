# frozen_string_literal: true

RSpec.shared_examples 'the configuration file does not exist' do
  it 'does not exist' do
    expect(config.config_file?).to be false
  end
end

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
      let(:default_options) { :invalid }
      let(:expected_error) { /default_options must be a Hash or ActiveSupport::HashWithIndifferentAccess/ }

      it_behaves_like 'an error is raised'
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
      # rubocop:disable Style/StringHashKeys - YAML writing/loading necessitates this
      let(:default_options) do
        {
          'editor' => 'editor',
          'entries_display_order' => 'entries_display_order',
          'entries_folder' => 'entries_folder',
          'entries_file_name' => 'entries_file_name',
          'carry_over_entries_to_today' => 'carry_over_entries_to_today',
          'include_all' => 'include_all'
        }
      end
      # rubocop:enable Style/StringHashKeys

      it_behaves_like 'the configuration file does not exist'

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
        # rubocop:disable Style/StringHashKeys - YAML writing/loading necessitates this
        Dsu::Support::Configuration::DEFAULT_DSU_OPTIONS.merge({
          'version' => 'changed version',
          'entries_file_name' => 'changed entries file name'
        })
        # rubocop:enable Style/StringHashKeys
      end

      it 'returns the default options merged with the configuration file options' do
        expect(configuration_loader_service.call).to eq default_options
      end
    end
  end
end
