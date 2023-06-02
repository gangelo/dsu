# frozen_string_literal: true

RSpec.describe Dsu::Services::Configuration::LoaderService do
  subject(:configuration_loader_service) { described_class.new(config_hash: config_hash) }

  let(:config_hash) { Dsu::Models::Configuration::DEFAULT_CONFIGURATION }

  describe '#initialize' do
    context 'when the arguments are valid' do
      it_behaves_like 'no error is raised'
    end

    # No errors are expected because the options are not
    # considered until #call is invoked.
    context 'when the arguments are invalid' do
      context 'when config_hash is nil' do
        let(:config_hash) { nil }
        let(:expected_error) { /config_hash is nil/ }

        it_behaves_like 'an error is raised'
      end

      context 'when config_hash is not a Hash' do
        let(:config_hash) { :invalid }
        let(:expected_error) { /config_hash must be a Hash/ }

        it_behaves_like 'an error is raised'
      end
    end
  end

  describe '#call' do
    context 'when the config_hash is valid' do
      it 'returns the passed options' do
        expect(configuration_loader_service.call).to eq Dsu::Models::Configuration.default
      end
    end

    context 'when the config_hash is invalid' do
      let(:config_hash) do
        default_config_hash = Dsu::Models::Configuration::DEFAULT_CONFIGURATION.dup
        Dsu::Models::Configuration.new(config_hash: default_config_hash).tap do |configuration|
          configuration.entries_folder = 'invalid'
          configuration.version = 'invalid'
        end.to_h
      end
      let(:expected_configuration) do
        Dsu::Models::Configuration.new(config_hash: config_hash)
      end

      it 'returns the passed options' do
        expect(configuration_loader_service.call).to eq expected_configuration
      end
    end
  end
end
