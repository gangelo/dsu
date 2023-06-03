# frozen_string_literal: true

RSpec.describe Dsu::Models::EntryGroup do
  subject(:entry_group) { build(:entry_group, time: time, entries: entries) }

  include_context 'with tmp'

  before do
    create_default_color_theme!
    create_config_file!
    Dsu::Models::EntryGroup.delete(time: time) if time.is_a?(Time)
  end

  after do
    delete_config_file!
    delete_default_color_theme!
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

  describe '#clone' do
    subject(:cloned_entry_group) { entry_group.clone }

    let(:entries) { build_list(:entry, 2) }

    it 'returns a new object' do
      expect(cloned_entry_group).not_to eq entry_group
    end

    it 'returns the entries in the same orded' do
      expect(cloned_entry_group.entries).to match_array entry_group.entries
    end

    it 'clones the entries' do
      result = cloned_entry_group.entries.each_with_index.any? do |entry, index|
        entry_group.entries[index].equal?(entry)
      end
      expect(result).to eq false
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

  describe '#entries=' do
    context 'when entries is nil' do
      before do
        entry_group.entries = nil
      end

      it 'uses an empty Array' do
        expect(entry_group.entries).to eq []
      end
    end

    context 'when entries is an empty Array' do
      before do
        entry_group.entries = []
      end

      it 'uses the empty Array' do
        expect(entry_group.entries).to eq []
      end
    end

    context 'when entries is not an Array' do
      subject(:entry_group) { build(:entry_group).entries = entries }

      let(:entries) { :not_an_array }
      let(:expected_error) { /entries is the wrong object type/ }

      it_behaves_like 'an error is raised'
    end

    context 'when entries contains non-Entry objects' do
      subject(:entry_group) { build(:entry_group, entries: entries) }

      let(:entries) do
        [
          build(:entry),
          :not_an_entry,
          build(:entry)
        ]
      end
      let(:expected_error) { /entries contains the wrong object type/ }

      it_behaves_like 'an error is raised'
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

  describe 'validation' do
    context 'when fields are valid' do
      it 'passes validation' do
        expect(entry_group.valid?).to be true
      end
    end

    context 'when there are duplicate entry descriptions' do
      subject(:entry_group) { build(:entry_group, time: time, entries: entries).validate! }

      let(:entries) { build_list(:entry, 2, description: 'duplicate') }
      let(:expected_error) { /Entries Array contains a duplicate entry/ }

      it_behaves_like 'an error is raised'
    end
  end

  describe 'class methods' do
    describe '.delete' do
      context 'when an entry group file exists for :time' do
        before do
          build(:entry_group, :with_entries, time: time).save!
        end

        after do
          Dsu::Models::EntryGroup.delete(time: time)
        end

        it 'exists before it is deleted' do
          expect(described_class.exists?(time: time)).to be true
        end

        it 'deletes the file' do
          described_class.delete!(time: time)
          expect(described_class.exists?(time: time)).to be false
        end
      end

      context 'when an entry group file does NOT exist for :time' do
        it 'does not exist before it is deleted' do
          expect(described_class.exists?(time: time)).to be false
        end

        it 'does NOT raise an error' do
          expect { described_class.delete!(time: time) }.not_to raise_error
        end
      end
    end

    describe '.edit' do
      before do
        Dsu::Models::EntryGroup.delete(time: time)
        allow(Dsu::Services::StdoutRedirectorService).to receive(:call).and_return(tmp_file_contents)
        editor = Dsu::Models::Configuration::DEFAULT_CONFIGURATION['editor']
        allow(Kernel).to receive(:system).with("${EDITOR:-#{editor}} #{tmp_file.path}").and_return(true)
      end

      after do
        Dsu::Models::EntryGroup.delete(time: time)
      end

      let!(:original_entry_group) { entry_group.clone }
      let(:tmp_file_contents) do
        # This simply simulates the user making entry group entry changes in the console.
        Dsu::Views::EntryGroup::Edit.new(entry_group: changed_entry_group).render_as_string
      end
      let(:changed_entry_group) do
        original_entry_group.clone.tap do |cloned_entry_group|
          cloned_entry_group.entries << build(:entry, description: 'Added entry 1')
          cloned_entry_group.entries << build(:entry, description: 'Added entry 2')
        end
      end

      it 'starts with no entry group file' do
        expect(Dsu::Models::EntryGroup.exist?(time: time)).to be false
      end

      it 'edits and saves the entry group file' do
        described_class.edit(time: time)
        expect(described_class.load(time: time).entries.size).to eq 2
      end
    end

    describe '.exists?' do
      context 'when an entry group file exists for :time' do
        after do
          Dsu::Models::EntryGroup.delete(time: time)
        end

        it 'returns true' do
          entry_group: create(:entry_group, :with_entries, time: time).save!
          expect(described_class.exists?(time: time)).to be true
        end
      end

      context 'when an entry group file does NOT exist for :time' do
        before do
          Dsu::Models::EntryGroup.delete(time: time)
        end

        it 'returns false' do
          expect(described_class.exists?(time: time)).to be false
        end
      end
    end

    describe '.load' do
      subject(:entry_group) { described_class.load(time: time) }

      context 'when an entry group file exists for :time and the entry group file has entries' do
        before do
          # Write our entry group to the file system so that when we
          # call our subject, it will load the entries from the file system.
          build(:entry_group, time: time, entries: entries).save!
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

      context 'when an entry group file exists for :time and the entry group file does NOT have entries' do
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
