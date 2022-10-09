# frozen_string_literal: true

RSpec.shared_examples 'validation fails' do
  it 'fails validation' do
    expect(entries.valid?).to be false
  end

  it 'returns the expected error messages' do
    expect(entries.errors.full_messages).to match_array expected_errors
  end
end

RSpec.describe Dsu::Support::Entries do
  subject(:entries) { described_class.new }

  describe '#initialize' do
    context 'when argument :date is not a Time object' do
      subject(:entries) { described_class.new date: :bad }

      it 'raises an error' do
        expect { entries }.to raise_error(/date is not a Time object/)
      end
    end

    context 'when argument :date is not passed' do
      it 'uses Time.now.utc' do
        expect(entries.date).to eq time_utc
      end
    end

    context 'when argument :date is passed' do
      subject(:entries) { described_class.new date: local_time }

      it 'uses the time passed converted to utc' do
        expect(entries.date).to eq local_time.utc
      end
    end

    context 'when there are entries to load' do
      subject(:entries) { described_class.new(date: local_time) }

      let(:entry_data) do
        {
          version: 'v0.1.0',
          date: time_utc,
          entries: [
            {
              order: 1,
              time: time_utc,
              description: '1 description',
              long_description: '1 long description',
              version: 'v0.1.0'
            },
            {
              order: 0,
              time: time_utc,
              description: '0 description',
              long_description: '0 long description',
              version: 'v0.1.0'
            }
          ]
        }
      end
      let(:hydrated_entry_data) do
        Dsu::Support::EntriesLoader.hydrate_entries(entries_hash: entry_data, date: time_utc)
      end
      let(:expected_entries) do
        entry_data[:entries].map do |entry|
          Dsu::Support::Entry.new(**entry)
        end
      end

      it 'loads the entries and #entries returns the entries as an Array' do
        expect(entries.entries).to match_array expected_entries
      end
    end

    context 'when the entries file does not exist' do
      subject(:entries) { described_class.new date: time_utc }

      let(:time_utc) { Time.parse('1900-01-01 00:00:00 UTC') }

      it '#version returns the current version' do
        expect(entries.version).to eq Dsu::Support::EntriesVersion::ENTRIES_VERSION
      end

      it '#date returns the date' do
        expect(entries.date).to eq time_utc
      end

      it '#entries returns an empty Array ([])' do
        expect(entries.entries).to eq []
      end
    end
  end

  describe '#required_fields' do
    it 'returns the correct required fields' do
      expect(described_class.new.required_fields).to match_array %i[date entries version]
    end
  end

  describe '#date' do
    context 'when date is blank or the wrong object type' do
      before do
        entries.date = nil
        entries.validate
      end

      let(:expected_errors) do
        [
          "Date can't be blank",
          'Date is the wrong object type. "Time" ' \
          'was expected, but "NilClass" was received.'
        ]
      end

      it_behaves_like 'validation fails'
    end
  end

  describe '#entries' do
    context 'when entries is nil' do
      before do
        entries.entries = nil
        entries.validate
      end

      let(:expected_errors) do
        [
          'Entries is the wrong object type. "Array" ' \
          'was expected, but "NilClass" was received.'
        ]
      end

      it_behaves_like 'validation fails'
    end

    context 'when entries is the wrong object type' do
      before do
        entries.entries = :bad
        entries.validate
      end

      let(:expected_errors) do
        [
          'Entries is the wrong object type. "Array" ' \
          'was expected, but "Symbol" was received.'
        ]
      end

      it_behaves_like 'validation fails'
    end

    context 'when entries elements are the wrong object type' do
      before do
        entries.entries = entries_array
        entries.validate
      end

      let(:entries_array) do
        [
          Dsu::Support::Entry.new(
            **{
              order: 1,
              time: time_utc,
              description: '1 description',
              long_description: '1 long description',
              version: '0.1.0'
            }
          ),
          { bad: :element },
          Dsu::Support::Entry.new(
            **{
              order: 0,
              time: local_time,
              description: '0 description',
              long_description: '0 long description',
              version: '0.1.0'
            }
          )
        ]
      end
      let(:expected_errors) do
        [
          'Entries entry Array element is the wrong object type. ' \
          '"Entry" was expected, but "Hash" was received.'
        ]
      end

      it_behaves_like 'validation fails'
    end
  end

  describe '#version' do
    context 'when version is blank or the wrong object type' do
      before do
        entries.version = nil
        entries.validate
      end

      let(:expected_errors) do
        [
          "Version can't be blank",
          'Version is the wrong object type. "String" ' \
          'was expected, but "NilClass" was received.'
        ]
      end

      it_behaves_like 'validation fails'
    end

    context 'when version is the wrong format' do
      before do
        entries.version = 'v1..0.0'
        entries.validate
      end

      let(:expected_errors) do
        [
          'Version is the wrong format. ' \
          'v\d+\.\d+\.\d+ format was expected, but "v1..0.0" was received.'
        ]
      end

      it_behaves_like 'validation fails'
    end
  end

  describe '#to_h' do
    subject(:entries) { described_class.new date: time_utc }

    let(:entry_data) do
      {
        version: 'v0.1.0',
        date: time_utc,
        entries:
          [
            {
              version: 'v0.1.0',
              order: 0,
              time: time_utc,
              description: '0 description',
              long_description: '0 long description'
            },
            {
              version: 'v0.1.0',
              order: 1,
              time: time_utc,
              description: '1 description',
              long_description: '1 long description'
            }
          ]
      }
    end

    it 'returns the entries data has a Hash' do
      expect(entries.to_h).to eq entry_data
    end
  end

  describe 'validation' do
    context 'when fields are valid' do
      it 'passes validation' do
        expect(entries.valid?).to be true
      end
    end
  end
end
