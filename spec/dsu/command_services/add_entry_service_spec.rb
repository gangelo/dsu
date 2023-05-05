# frozen_string_literal: true

RSpec.describe Dsu::CommandServices::AddEntryService do
  subject(:add_entry_service) { described_class.new(entry: entry, time: time) }

  let(:entry) { build(:entry) }
  let(:time) { Time.now }

  describe '#initialize' do
    context 'when the arguments are valid' do
      it_behaves_like 'no error is raised'
    end

    context 'when the arguments are invalid' do
      context 'when the entry is nil' do
        let(:entry) { nil }

        let(:expected_error) { /entry is nil/ }

        it_behaves_like 'an error is raised'
      end

      context 'when the entry is the wrong object type' do
        let(:entry) { :invalid }

        let(:expected_error) { /entry is the wrong object type/ }

        it_behaves_like 'an error is raised'
      end

      context 'when :time is nil' do
        let(:time) { nil }

        let(:expected_error) { /time is nil/ }

        it_behaves_like 'an error is raised'
      end

      context 'when :time is the wrong object type' do
        let(:time) { :invalid }

        let(:expected_error) { /time is the wrong object type/ }

        it_behaves_like 'an error is raised'
      end
    end
  end

  describe '#call' do
    subject(:add_entry_service) { described_class.new(entry: entry, time: time).call }

    context 'when the entry is not added' do
      before do
        entry.description = nil
      end

      let(:entry) { build(:entry) }
      let(:expected_error) { ActiveModel::ValidationError }

      it_behaves_like 'an error is raised'
    end

    context 'when the entry is added' do
      before do
        delete_entry_group_file!(time: time.utc)
        add_entry_service
      end

      it 'returns the entry uuid' do
        expect(add_entry_service).to eq entry.uuid
      end

      it 'creates the entry group file' do
        expect(entry_group_file_exists?(time: time.utc)).to be true
      end

      it 'creates the entry group file with the correct json' do
        expected_entry_group_hash = {
          time: time.utc,
          entries: [entry.to_h]
        }
        expect(entry_group_file_matches?(time: time.utc, entry_group_hash: expected_entry_group_hash)).to be true
      end
    end
  end
end
