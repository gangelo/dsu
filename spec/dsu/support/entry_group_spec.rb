# frozen_string_literal: true

RSpec.describe Dsu::Support::EntryGroup do
  subject(:entry_group) { build(:entry_group, time: time) }

  before(:all) do
    config.create_config_file!
  end

  before do
    stub_entries_version
    delete_entry_group_file!(time: time.utc) if time.is_a?(Time)
  end

  after(:all) do
    config.delete_config_file!
  end

  let(:time) { nil }

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
      before do
        # Write our entry group to the file system so that when we
        # call our subject, it will load the entries from the file system.
        build(:entry_group, time: time, entries: entries).tap do |entry_group|
          create_entry_group_file!(entry_group: entry_group)
        end
      end

      let(:time) { local_time }
      let(:entries) { build_list(:entry, 2, time: time) }
      let(:entry_group_hash) do
        {
          version: entries_version,
          time: time.utc,
          entries: entries.map(&:to_h)
        }
      end

      it 'loads the entries and #entries returns the entries as an Array' do
        expect(entry_group.to_h).to match_array entry_group_hash
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
          build(:entry, time: time),
          :not_an_entry,
          build(:entry, time: time)
        ]
      end
      let(:expected_errors) do
        [
          'Entries entry Array element is the wrong object type. ' \
          '"Entry" was expected, but "Symbol" was received.'
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
          '\d+\.\d+\.\d+ format was expected, but "1..0.0" was received.'
        ]
      end

      it_behaves_like 'the validation fails'
    end
  end

  describe '#to_h' do
    subject(:entry_group) { build(:entry_group, time: time, entries: entries) }

    let(:time) { time_utc }
    let(:entries) { build_list(:entry, 2, time: time) }
    let(:entry_group_hash) do
      {
        version: entries_version,
        time: time,
        entries: [
          entries[0].to_h,
          entries[1].to_h
        ]
      }
    end

    it 'returns the entries data has a Hash' do
      expect(entry_group.to_h).to match entry_group_hash
    end
  end

  describe '#to_h_localized' do
    subject(:entry_group) { build(:entry_group, time: time, entries: entries) }

    let(:time) { time_utc }
    let(:entries) { build_list(:entry, 2, time: time) }
    let(:localized_entry_group_hash) do
      {
        version: entries_version,
        time: time.localtime,
        entries: [
          entries[0].to_h_localized,
          entries[1].to_h_localized
        ]
      }
    end

    it 'returns a Hash representing the entry group with dates/times localized' do
      expect(entry_group.to_h_localized).to eq localized_entry_group_hash
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
