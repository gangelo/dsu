# frozen_string_literal: true

RSpec.describe Dsu::CommandServices::AddEntryService do
  let(:entry) { build(:entry) }
  let(:time) { Time.now }

  describe '#initialize' do
    subject(:add_entry_service) { described_class.new(entry: entry, time: time) }

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

    context 'when an entry fails validation' do
      let(:entry) { build(:entry, :invalid) }
      let(:expected_error) { ActiveModel::ValidationError }

      it 'writes an error message to the console' do
        expect { add_entry_service }.to output(/An error was encountered; the entry could not be added added/).to_stdout
      end

      it 'does not add the entry' do
        # If the entry was added, the entry group file would have been created.
        # Checking the existance of the entry group file is a good way to ensure
        # that the entry was not added.
        expect(Dsu::Models::EntryGroup.exist?(time: time)).not_to be true
      end
    end

    context 'when the entry is added' do
      before do
        add_entry_service
      end

      it 'creates the entry group file' do
        expect(Dsu::Models::EntryGroup.exist?(time: time)).to be true
      end

      it 'creates the entry group file with the correct json' do
        expected_entry_group_hash = {
          time: time,
          entries: [entry.to_h]
        }

        expect(entry_group_file_matches?(time: time, entry_group_hash: expected_entry_group_hash)).to be true
      end
    end
  end
end
