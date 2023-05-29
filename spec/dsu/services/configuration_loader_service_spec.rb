# frozen_string_literal: true

RSpec.shared_examples 'the configuration file does not exist' do
  it 'does not exist' do
    expect(config.config_file_exist?).to be false
  end
end

RSpec.describe Dsu::Services::ConfigurationLoaderService do
  subject(:configuration_loader_service) { described_class.new(default_options: default_options) }

  before do
    create_config_file!
  end

  after do
    delete_config_file!
  end

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
      before do
        delete_config_file!
      end

      # rubocop:disable Style/StringHashKeys - YAML writing/loading necessitates this
      let(:default_options) do
        {
          'version' => 'version',
          'editor' => 'editor',
          'entries_display_order' => 'entries_display_order',
          'entries_folder' => 'entries_folder',
          'entries_file_name' => 'entries_file_name',
          'carry_over_entries_to_today' => 'carry_over_entries_to_today',
          'include_all' => 'include_all',
          'theme' => 'theme',
          'themes_folder' => 'themes_folder'
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

      it 'returns the configuration file options' do
        expect(configuration_loader_service.call).to eq default_configuration
      end
    end

    context 'when default options are passed and the configuration file does exist' do
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

    context 'when the configuration file exists and migrations are needed' do
      before do
        stub_const('Dsu::Support::Configuration::DEFAULT_DSU_OPTIONS', mocked_default_options)

        # Mock the configuration migration service so that we can make sure it is
        # called to migrate the configuration if the config version is not
        # current.
        allow(Dsu::Migration::ConfigurationMigratorService).to receive(:new).and_return(mocked_migration_service)
        allow(mocked_migration_service).to receive(:call)
      end

      let(:mocked_migration_service) { instance_double(Dsu::Migration::ConfigurationMigratorService) }

      # These options represent (for example) a user updates this gem, the default
      # configuration has changed to include a more recent version.
      let(:mocked_default_options) do
        Dsu::Support::Configuration::DEFAULT_DSU_OPTIONS.dup.tap do |default_options|
          default_options['version'] = default_options['version'].gsub(/\d+\.\d+\.\d+/, '100.0.0')
        end
      end

      # TODO: This test won't pass until the migration service is implemented.
      it 'runs migrations for color themes' do
        configuration_loader_service.call
        expect(mocked_migration_service).to have_received(:call).once
      end
    end
  end
end
