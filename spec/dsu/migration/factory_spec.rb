# frozen_string_literal: true

RSpec.describe Dsu::Migration::Factory do
  let(:options) { {} }

  describe '.migrate_if!' do
    before do
      create(:migration_version, version: version)
    end

    context 'when the migration version is not 20230613121411' do
      before do
        allow(Dsu::Migration::Service20240210161248).to receive(:new) # Stub the :new method
        described_class.migrate_if!(options: options)
      end

      let(:version) { 0 }

      it 'does not call the migration service' do
        expect(Dsu::Migration::Service20240210161248).to_not have_received(:new)
      end
    end

    context 'when the migration version is 20230613121411' do
      before do
        create(:migration_version, version: 20230613121411) # rubocop:disable Style/NumericLiterals
        allow(Dsu::Migration::Service20240210161248).to receive(:new).and_call_original # Stub :new but allow it to call the original method
        described_class.migrate_if!(options: options)
      end

      let(:version) { 20230613121411 } # rubocop:disable Style/NumericLiterals

      it 'calls the migration service' do
        expect(Dsu::Migration::Service20240210161248).to have_received(:new)
      end
    end
  end
end
