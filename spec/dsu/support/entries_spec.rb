# frozen_string_literal: true

RSpec.describe Dsu::Support::Entries do
  subject(:entries) { described_class.new time: time }

  before do
    stub_entries_version
  end

  describe '#initialize' do
    context 'when argument :time is not a Time object' do
      let(:time) { :bad }
      let(:expected_error) { /time is the wrong object type/ }

      it_behaves_like 'an error is raised'
    end

    context 'when argument :time is nil' do
      let(:time) { nil }

      it 'uses Time.now.utc' do
        expect(entries.time).to eq time_utc
      end
    end

    context 'when argument :time is passed' do
      let(:time) { local_time }

      it 'uses the time passed converted to utc' do
        expect(entries.time).to eq local_time.utc
      end
    end

    context 'when there are entries to load' do
      let(:time) { local_time }
      let(:hydrated_entry_data) do
        Dsu::Support::EntriesLoader.hydrate_entries(entries_hash: entries_hash, time: time_utc)
      end
      let(:expected_entries) do
        entries_hash[:entries].map do |entry|
          Dsu::Support::Entry.new(**entry)
        end
      end

      it 'loads the entries and #entries returns the entries as an Array' do
        expect(entries.entries).to match_array expected_entries
      end
    end

    context 'when the entries file does not exist' do
      let(:time) { time_utc }
      let(:time_utc) { Time.parse('1900-01-01 00:00:00 UTC') }

      it '#version returns the current version' do
        expect(entries.version).to eq Dsu::Support::EntriesVersion::ENTRIES_VERSION
      end

      it '#time returns the time' do
        expect(entries.time).to eq time_utc
      end

      it '#entries returns an empty Array ([])' do
        expect(entries.entries).to eq []
      end
    end
  end

  describe '#required_fields' do
    it 'returns the correct required fields' do
      expect(described_class.new.required_fields).to match_array %i[time entries version]
    end
  end

  describe '#time' do
    context 'when time is blank or the wrong object type' do
      before do
        entries.time = nil
        entries.validate
      end

      let(:time) { time_utc }
      let(:expected_errors) do
        [
          "Time can't be blank",
          'Time is the wrong object type. "Time" ' \
          'was expected, but "NilClass" was received.'
        ]
      end

      it_behaves_like 'the validation fails'
    end
  end

  describe '#entries' do
    context 'when entries is nil' do
      before do
        entries.entries = nil
        entries.validate
      end

      let(:time) { time_utc }
      let(:expected_errors) do
        [
          'Entries is the wrong object type. "Array" ' \
          'was expected, but "NilClass" was received.'
        ]
      end

      it_behaves_like 'the validation fails'
    end

    context 'when entries is the wrong object type' do
      before do
        entries.entries = :bad
        entries.validate
      end

      let(:time) { time_utc }
      let(:expected_errors) do
        [
          'Entries is the wrong object type. "Array" ' \
          'was expected, but "Symbol" was received.'
        ]
      end

      it_behaves_like 'the validation fails'
    end

    context 'when entries elements are the wrong object type' do
      before do
        entries.entries = entries_array
        entries.validate
      end

      let(:time) { time_utc }
      let(:entries_array) do
        [
          Dsu::Support::Entry.new(**entry_1_hash),
          { bad: :element },
          Dsu::Support::Entry.new(**entry_0_hash)
        ]
      end
      let(:expected_errors) do
        [
          'Entries entry Array element is the wrong object type. ' \
          '"Entry" was expected, but "Hash" was received.'
        ]
      end

      it_behaves_like 'the validation fails'
    end
  end

  describe '#version' do
    context 'when version is nil' do
      before do
        entries.version = nil
        entries.validate
      end

      let(:time) { time_utc }
      let(:expected_errors) do
        [
          'Version is the wrong object type. "String" ' \
          'was expected, but "NilClass" was received.'
        ]
      end

      it_behaves_like 'the validation fails'
    end

    context 'when version is blank?' do
      before do
        entries.version = ''
        entries.validate
      end

      let(:time) { time_utc }
      let(:expected_errors) do
        [
          "Version can't be blank"
        ]
      end

      it_behaves_like 'the validation fails'
    end

    context 'when version is the wrong format' do
      before do
        entries.version = 'v1..0.0'
        entries.validate
      end

      let(:time) { time_utc }
      let(:expected_errors) do
        [
          'Version is the wrong format. ' \
          'v\d+\.\d+\.\d+ format was expected, but "v1..0.0" was received.'
        ]
      end

      it_behaves_like 'the validation fails'
    end
  end

  describe '#to_h' do
    let(:time) { time_utc }

    it 'returns the entries data has a Hash' do
      expect(entries.to_h).to match entries_hash_with_sorted_entries
    end
  end

  describe '#to_h_localized' do
    let(:time) { time_utc }

    it 'returns a Hash representing the Entries with dates/times localized' do
      expect(entries.to_h_localized).to eq entries_hash_with_sorted_entries
    end
  end

  describe 'validation' do
    context 'when fields are valid' do
      let(:time) { time_utc }

      it 'passes validation' do
        expect(entries.valid?).to be true
      end
    end
  end
end
