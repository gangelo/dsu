# frozen_string_literal: true

RSpec.describe Dsu::Models::EntryGroup do
  subject(:entry_group) { build(:entry_group, time: time, entries: entries) }

  before(:all) do
    config.create_config_file!
  end

  before do
    delete_entry_group_file!(time: time) if time.is_a?(Time)
  end

  after(:all) do
    config.delete_config_file!
  end

  let(:time) { time_utc }
  let(:entries) { [] }

  describe '#initialize' do
    describe 'argument :time' do
      context 'when not a Time object' do
        let(:time) { :bad }
        let(:expected_error) { /time is the wrong object type/ }

        it_behaves_like 'an error is raised'
      end

      context 'when nil' do
        let(:time) { nil }

        it 'uses Time.now' do
          expect(entry_group.time).to eq time_utc
        end
      end

      context 'when utc' do
        let(:time) { time_utc }

        it 'uses it' do
          expect(entry_group.time).to eq time_utc
        end
      end

      context 'when localized' do
        let(:time) { local_time }

        it 'converts it to utc' do
          expect(entry_group.time).to eq time
        end
      end
    end

    describe 'argument :entries' do
      context 'when not an Array' do
        let(:entries) { :bad }
        let(:expected_error) { /entries is the wrong object type/ }

        it_behaves_like 'an error is raised'
      end

      context 'when nil' do
        let(:entries) { nil }

        it 'uses an empty Array' do
          expect(entry_group.entries).to eq []
        end
      end

      context 'when an Array' do
        let(:entries) { [build(:entry)] }

        it 'uses it' do
          expect(entry_group.entries).to eq entries
        end
      end
    end
  end

  describe '#required_fields' do
    it 'returns the correct required fields' do
      expect(described_class.new(time: time).required_fields).to match_array %i[time entries]
    end
  end

  describe '#time' do
    context 'when time is nil?' do
      before do
        entry_group.time = nil
        entry_group.validate
      end

      let(:expected_errors) do
        [
          "Time can't be blank"
        ]
      end

      it_behaves_like 'the validation fails'
    end

    context 'when time is the wrong object type' do
      before do
        entry_group.time = :wrong_type
        entry_group.validate
      end

      let(:expected_errors) do
        [
          'Time is the wrong object type. "Time" ' \
          'was expected, but "Symbol" was received.'
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

      let(:entries_array) do
        [
          build(:entry),
          :not_an_entry,
          build(:entry)
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

  describe '#to_h' do
    subject(:entry_group) { build(:entry_group, time: time, entries: entries) }

    let(:entries) { build_list(:entry, 2) }
    let(:entry_group_hash) do
      {
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

    let(:entries) { build_list(:entry, 2) }
    let(:localized_entry_group_hash) do
      {
        time: time.localtime,
        entries: [
          entries[0].to_h,
          entries[1].to_h
        ]
      }
    end

    it 'returns a Hash representing the entry group with dates/times localized' do
      expect(entry_group.to_h_localized).to eq localized_entry_group_hash
    end
  end

  describe 'validation' do
    context 'when fields are valid' do
      it 'passes validation' do
        expect(entry_group.valid?).to be true
      end
    end
  end

  describe 'class methods' do
    describe '.load' do
      subject(:entry_group) { described_class.load(time: time) }

      context 'when an entry group file exists for :time' do
        context 'when the entry group file has entries' do
          before do
            # Write our entry group to the file system so that when we
            # call our subject, it will load the entries from the file system.
            build(:entry_group, time: time, entries: entries).tap do |entry_group|
              create_entry_group_file!(entry_group: entry_group)
            end
          end

          let(:entries) { build_list(:entry, 2) }
          let(:entry_group_hash) do
            {
              time: time,
              entries: entries.map(&:to_h)
            }
          end

          it 'loads the entry group and entries' do
            expect(entry_group.to_h).to match_array entry_group_hash
          end
        end

        context 'when the entry group file does NOT have entries' do
          context 'when the entry group file has entries' do
            let(:entries) { [] }
            let(:entry_group_hash) do
              {
                time: time,
                entries: entries
              }
            end

            it 'loads the entry group and entries is initialized to an empty Array' do
              expect(entry_group.to_h).to match_array entry_group_hash
            end
          end
        end
      end

      context 'when an entry group file does NOT exists for :time' do
        let(:time) { time_utc }
        let(:time_utc) { Time.parse('1900-01-01 00:00:00 UTC') }

        it '#time returns the time' do
          expect(entry_group.time).to eq time_utc
        end

        it '#entries returns an empty Array ([])' do
          expect(entry_group.entries).to eq []
        end
      end
    end
  end
end
