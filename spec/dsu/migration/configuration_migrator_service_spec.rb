# frozen_string_literal: true

RSpec.describe Dsu::Migration::ConfigurationMigratorService do
  subject(:configuration_migrator_service) { described_class.new(config_hash: config_hash) }

  include_context 'with migrations'

  after do
    delete_config_file!
  end

  let(:config_hash) { nil }
  let(:default_configuration) { Dsu::Models::Configuration::DEFAULT_CONFIGURATION }

  describe '#initialize' do
    context 'when the arguments are invalid' do
      context 'when config_hash is an empty Hash' do
        let(:config_hash) { {} }
        let(:expected_error) { /config_hash is empty/ }

        it_behaves_like 'an error is raised'
      end

      context 'when config_hash is not a Hash' do
        let(:config_hash) { 'not a hash' }
        let(:expected_error) { /config_hash must be a Hash/ }

        it_behaves_like 'an error is raised'
      end
    end

    context 'when the configuration file does not exist' do
      context 'when config_hash is nil' do
        it 'uses the default configuration' do
          expect(configuration_migrator_service.config_hash).to eq default_configuration
        end
      end

      context 'when config_hash is not nil' do
        let(:config_hash) { default_configuration.merge('foo' => :bar) } # rubocop:disable Style/StringHashKeys

        it 'uses the config_hash' do
          expect(configuration_migrator_service.config_hash).to eq config_hash
        end
      end
    end

    context 'when the configuration file exists' do
      context 'when config_hash is nil' do
        before do
          create_config_file_using!(config_hash: expected_config_hash)
        end

        let(:expected_config_hash) { default_configuration.merge('foo' => :bar) } # rubocop:disable Style/StringHashKeys

        it 'uses the default configuration' do
          expect(configuration_migrator_service.config_hash).to eq expected_config_hash
        end
      end

      context 'when config_hash is not nil' do
        let(:config_hash) { default_configuration.merge('foo' => :bar) }

        it 'uses the config_hash' do
          expect(configuration_migrator_service.config_hash).to eq config_hash
        end
      end
    end
  end

  describe '#call' do
    subject(:configuration_migrator_service_call) { configuration_migrator_service.call }

    let(:expected_error) { /You must implement the #migration_version method/ }

    it_behaves_like 'an error is raised'
  end

  context 'when subclassed' do
    subject(:migrator_service) { Dsu::Migration::MigratorService }

    context 'when the configuration file does not exist' do
      context 'when there are migrations to run' do
        let(:expected_output) do
          <<~OUTPUT
            Running migration: 20230530232949_config_migration01.rb...
            Running migration: 20230530232950_config_migration02.rb...
            Running migration: 20230530232951_config_migration03.rb...
          OUTPUT
        end

        it 'displays ?' do
          expect do
            migrator_service.run_migrations!
          end.to output(/#{expected_output.chomp}/).to_stdout
        end
      end
    end

    xcontext 'when the configuration file exists' do
      before do
        create_config_file!
      end

      context 'when there are migrations to run' do
        let(:expected_output) do
          <<~OUTPUT
            Running migration: 20230530232949_config_migration01.rb...
            Running migration: 20230530232950_config_migration02.rb...
            Running migration: 20230530232951_config_migration03.rb...
          OUTPUT
        end

        it 'displays the migration as they are running' do
          expect do
            configuration_migrator_service.call
          end.to output(/#{expected_output}/).to_stdout
        end
      end
    end
  end
end
