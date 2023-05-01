# frozen_string_literal: true

RSpec.describe Dsu::Support::EntryGroup do
  subject(:entry_group) { described_class.new time: time }

  before do
    stub_entries_version
  end

  before do
    config.create_config_file!
  end

  after do
    config.delete_config_file!
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
        expect(entry_group.time).to eq time_utc
      end
    end

    context 'when argument :time is passed' do
      let(:time) { local_time }

      it 'uses the time passed converted to utc' do
        expect(entry_group.time).to eq local_time.utc
      end
    end

    context 'when there are entries to load' do
      let(:time) { local_time }
      let(:expected_entries) do
        entry_group_hash[:entries].map do |entry|
          Dsu::Support::Entry.new(**entry)
        end
      end

      it 'loads the entries and #entries returns the entries as an Array' do
        expect(entry_group.entries).to match_array expected_entries
      end
    end

    context 'when the entries file does not exist' do
      let(:time) { time_utc }
      let(:time_utc) { Time.parse('1900-01-01 00:00:00 UTC') }

      it '#version returns the current version' do
        expect(entry_group.version).to eq Dsu::Support::EntriesVersion::ENTRIES_VERSION
      end

      it '#time returns the time' do
        expect(entry_group.time).to eq time_utc
      end

      it '#entries returns an empty Array ([])' do
        expect(entry_group.entries).to eq []
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
        entry_group.time = nil
        entry_group.validate
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
        entry_group.entries = nil
        entry_group.validate
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
        entry_group.entries = :bad
        entry_group.validate
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
        entry_group.entries = entries_array
        entry_group.validate
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
        entry_group.version = nil
        entry_group.validate
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
        entry_group.version = ''
        entry_group.validate
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
        entry_group.version = '1..0.0'
        entry_group.validate
      end

      let(:time) { time_utc }
      let(:expected_errors) do
        [
          'Version is the wrong format. ' \
          'v\d+\.\d+\.\d+ format was expected, but "1..0.0" was received.'
        ]
      end

      it_behaves_like 'the validation fails'
    end
  end

  describe '#to_h' do
    let(:time) { time_utc }

    it 'returns the entries data has a Hash' do
      expect(entry_group.to_h).to match entries_hash_with_sorted_entries
    end
  end

  describe '#to_h_localized' do
    let(:time) { time_utc }

    it 'returns a Hash representing the Entries with dates/times localized' do
      expect(entry_group.to_h_localized).to eq entries_hash_with_sorted_entries
    end
  end

  describe 'validation' do
    context 'when fields are valid' do
      let(:time) { time_utc }

      it 'passes validation' do
        expect(entry_group.valid?).to be true
      end
    end
  end
end
