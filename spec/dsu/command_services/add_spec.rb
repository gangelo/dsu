# frozen_string_literal: true

RSpec.describe Dsu::CommandServices::Add do
  subject(:add) { described_class.new(entry: entry, time: time) }

  let(:entry) { build(:entry) }
  let(:time) { Time.now }

  describe '#initialize' do
    context 'when the arguments are valid' do
      it 'does not raise an error' do
        expect { add }.not_to raise_error
      end
    end

    # No errors are expected because the entry is not validated
    # until #call is invoked.
    context 'when the arguments are invalid' do
      let(:description) { nil }

      it_behaves_like 'no error is raised'
    end
  end

  describe '#call' do
    subject(:add) { described_class.new(entry: entry, time: time).call }

    context 'when the entry is not added' do
      let(:entry) { build(:entry, :invalid) }
      let(:expected_error) { ActiveModel::ValidationError }

      it_behaves_like 'an error is raised'
    end

    context 'when the entry is added' do
      before do
        add
      end

      it 'returns the entry uuid' do
        expect(add).to eq entry.uuid
      end

      it 'adds the entry to the entry group for the time' do
        Dsu::Support::EntryGroup.new(time: time).tap do |entry_group|
          expect(entry_group.entries).to include entry
        end
      end
    end
  end
end
