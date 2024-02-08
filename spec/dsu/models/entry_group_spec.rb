# frozen_string_literal: true

RSpec.describe Dsu::Models::EntryGroup do
  subject(:entry_group) { build(:entry_group, time: time, entries: entries) }

  before do
    build(:configuration, config_hash: Dsu::Models::Configuration::DEFAULT_CONFIGURATION)
  end

  let(:time) { Time.now }
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
          expect(!entry_group.time.utc?).to be true
        end
      end

      context 'when utc' do
        let(:time) { Time.now.utc }

        it 'converts it to localtime' do
          expect(entry_group.time).to eq time.in_time_zone
        end
      end

      context 'when localized' do
        let(:time) { Time.now }

        it 'keeps the time localtime' do
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
      expect(cloned_entry_group).to_not equal entry_group
    end

    it 'returns the entries in the same orded' do
      expect(cloned_entry_group.entries).to match_array entry_group.entries
    end

    it 'clones the entries' do
      result = cloned_entry_group.entries.each_with_index.any? do |entry, index|
        entry_group.entries[index].equal?(entry)
      end
      expect(result).to be false
    end
  end

  describe '#delete' do
    context 'when the entry group file exists' do
      before do
        create(:entry_group, :with_entries, time: time)
      end

      it 'deletes the entry group along with the entries' do
        expect(entry_group.delete).to eq(entry_group.entries)
        expect(entry_group.exist?).to be false
        expect(File.exist?(entry_group.file_path)).to be false
      end
    end

    context 'when the entry group file does NOT exist' do
      before do
        build(:entry_group, :with_entries, time: time)
      end

      it 'returns the entry group entries if any' do
        expect(entry_group.delete).to eq(entry_group.entries)
      end
    end
  end

  describe '#delete!' do
    context 'when the entry group file exists' do
      before do
        create(:entry_group, :with_entries, time: time)
      end

      it 'deletes the entry group along with the entries' do
        expect(entry_group.delete!).to eq(entry_group.entries)
        expect(entry_group.exist?).to be false
        expect(File.exist?(entry_group.file_path)).to be false
      end
    end

    context 'when the entry group file does NOT exist' do
      before do
        build(:entry_group, :with_entries, time: time)
      end

      it 'raises an error' do
        expect { entry_group.delete! }.to raise_error(/File .+ does not exist/)
      end
    end
  end

  describe '#hash' do
    let(:expected_hash) do
      entry_group.entries.map(&:hash).tap do |hashes|
        hashes << entry_group.version.hash
        hashes << Dsu::Support::TimeComparable.time_equal_compare_string_for(time: entry_group.time)
      end.hash
    end

    it 'returns the entry group hash' do
      expect(entry_group.hash).to eq expected_hash
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

  describe '#time_yyyy_mm_dd' do
    it 'returns the time formatted as yyyy-mm-dd' do
      expect(entry_group.time_yyyy_mm_dd).to eq entry_group.time.strftime('%Y-%m-%d')
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
        version: entry_group.version,
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
    it 'validates #version attribute with the VersionValidator' do
      expect(described_class).to validate_with_validator(Dsu::Validators::VersionValidator)
    end

    it 'validates #entries attribute with the EntriesValidator' do
      expect(described_class).to validate_with_validator(Dsu::Validators::EntriesValidator)
    end

    it 'validates #time with TimeValidator' do
      expect(described_class).to validate_with_validator(Dsu::Validators::TimeValidator)
    end

    context 'when fields are valid' do
      it 'passes validation' do
        expect(entry_group.valid?).to be true
      end
    end

    context 'when there are duplicate entry descriptions' do
      subject(:entry_group) { build(:entry_group, time: time, entries: entries).validate! }

      let(:entries) { build_list(:entry, 2, description: 'duplicate') }
      let(:expected_error) { /Entries array contains duplicate entry/ }

      it_behaves_like 'an error is raised'
    end
  end

  describe 'class methods' do
    describe '.all' do
      subject(:all_entry_groups) { described_class.all }

      context 'when there are entry group files' do
        before do
          create(:entry_group, :with_entries, time: time.yesterday)
          create(:entry_group, :with_entries, time: time)
          create(:entry_group, :with_entries, time: time.tomorrow)
        end

        it 'returns all the entry groups' do
          expect(all_entry_groups.count).to eq 3
        end
      end

      context 'when there are NO entry groups' do
        it 'returns an empty Array' do
          expect(all_entry_groups).to eq []
        end
      end
    end

    describe '.any' do
      subject(:any_entry_groups) { described_class.any? }

      context 'when there are entry group files' do
        before do
          create(:entry_group, :with_entries, time: time)
        end

        it 'returns true' do
          expect(any_entry_groups).to be true
        end
      end

      context 'when there are NO entry groups' do
        it 'returns false' do
          expect(any_entry_groups).to be false
        end
      end
    end

    describe '.delete' do
      context 'when an entry group file exists for :time' do
        before do
          create(:entry_group, :with_entries, time: time)
        end

        it 'exists before it is deleted' do
          expect(described_class.exist?(time: time)).to be true
        end

        it 'deletes the file' do
          described_class.delete!(time: time)
          entry_path = Dsu::Support::Fileable.entries_path(time: time)
          expect(File.exist?(entry_path)).to be false
        end
      end

      context 'when an entry group file does NOT exist for :time' do
        it 'does not exist before it is deleted' do
          entry_path = Dsu::Support::Fileable.entries_path(time: time)
          expect(File.exist?(entry_path)).to be false
        end

        it 'does NOT raise an error' do
          expect { described_class.delete(time: time) }.to_not raise_error
        end
      end
    end

    describe '.edit' do
      before do
        allow(Dsu::Services::StdoutRedirectorService).to receive(:call).and_return(tmp_file_contents)
        editor = Dsu::Models::Configuration::DEFAULT_CONFIGURATION[:editor]
        allow(Kernel).to receive(:system).with("${EDITOR:-#{editor}} #{temp_file.path}").and_return(true)
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
        expect(described_class.exist?(time: time)).to be false
      end

      it 'edits and saves the entry group file' do
        described_class.edit(time: time)
        expect(described_class.find(time: time).entries.size).to eq 2
      end
    end

    describe '.entry_groups' do
      let(:times) { times_for_week_of(Time.now.localtime) }

      context 'when there are entry groups' do
        before do
          entry_groups
        end

        let(:entry_groups) do
          times.map do |time|
            create(:entry_group, :with_entries, time: time)
          end
        end

        it 'returns the entry groups' do
          expected_entry_groups = entry_groups[1..-2]
          expect(described_class.entry_groups(between: times[1..-2])).to match_array(expected_entry_groups)
        end
      end

      context 'when there are no entry groups' do
        it 'returns an empty array' do
          expect(described_class.entry_groups(between: times[1..-2])).to eq []
        end
      end
    end

    describe '.entry_group_times' do
      context 'when there are entry groups' do
        before do
          times.map do |time|
            create(:entry_group, :with_entries, time: time)
          end
        end

        let(:times) { times_for_week_of(Time.now.localtime) }

        it 'returns the entry group times' do
          expected_times = times[1..-2].map { |time| time.to_date.to_s }
          expect(described_class.entry_group_times(between: times[1..-2])).to match_array(expected_times)
        end
      end

      context 'when there are no entry groups' do
        let(:times) { times_for_week_of(Time.now.localtime) }

        it 'returns an empty array' do
          expect(described_class.entry_group_times(between: times)).to eq []
        end
      end
    end

    describe '.find' do
      subject(:entry_group) { described_class.find(time: time) }

      context 'when an entry group file exists' do
        before do
          expected_entry_group
        end

        let(:expected_entry_group) { create(:entry_group, :with_entries, time: time) }

        it 'returns the entry group' do
          expect(entry_group).to eq expected_entry_group
        end
      end

      context 'when an entry group file does NOT exists' do
        let(:expected_error) { /File ".+" does not exist/ }

        it_behaves_like 'an error is raised'
      end
    end

    describe '.find_or_initialize' do
      context 'when the entry group file exists' do
        before do
          entry_group
          allow(described_class).to receive(:find_or_initialize).and_call_original
        end

        let(:time) { Time.now.localtime }
        let(:entry_group) { create(:entry_group, :with_entries, time: time) }

        it 'returns the existing entry group' do
          expect(described_class.find_or_initialize(time: time)).to eq entry_group
          expect(described_class).to have_received(:find_or_initialize).exactly(1).times
        end
      end

      context 'when the entry group file does NOT exist' do
        before do
          entry_group
          allow(described_class).to receive(:new).and_call_original
        end

        let(:time) { Time.now.localtime }
        let(:entry_group) { build(:entry_group, :with_entries, time: time) }

        it 'returns the created entry group' do
          expect(described_class.find_or_initialize(time: time).time).to eq time
          expect(described_class).to have_received(:new).exactly(1).times
          expect(entry_group.exist?).to be false
        end
      end
    end

    describe '.write' do
      subject(:entry_group_write) do
        file_data = entry_group.to_h
        file_path = entry_group.file_path
        described_class.write(file_data: file_data, file_path: file_path)
      end

      context 'when the entry group file exists and there are entries' do
        let(:time) { Time.now.localtime }
        let(:entry_group) { create(:entry_group, :with_entries, time: time) }

        it 'writes the entry group to disk' do
          expect { entry_group_write }.to_not raise_error
          expect(entry_group.exist?).to be true
        end
      end

      context 'when the entry group file exists and there are no entries' do
        let(:time) { Time.now.localtime }
        let(:entry_group) { create(:entry_group, :with_entries, time: time) }

        it 'deletes the entry group file' do
          entry_group.entries = []
          expect { entry_group_write }.to_not raise_error
          expect(entry_group.exist?).to be false
        end
      end

      context 'when the entry group does not exist and has no entries' do
        let(:time) { Time.now.localtime }
        let(:entry_group) { build(:entry_group, time: time) }

        it 'does not write the entry group file to disk' do
          expect { entry_group_write }.to_not raise_error
          expect(entry_group.exist?).to be false
        end
      end
    end

    describe '.write!' do
      subject(:entry_group_write) do
        file_data = entry_group.to_h
        file_path = entry_group.file_path
        described_class.write!(file_data: file_data, file_path: file_path)
      end

      context 'when the entry group file exists and there are entries' do
        let(:time) { Time.now.localtime }
        let(:entry_group) { create(:entry_group, :with_entries, time: time) }

        it 'writes the entry group to disk' do
          expect { entry_group_write }.to_not raise_error
          expect(entry_group.exist?).to be true
        end
      end

      context 'when the entry group file exists and there are no entries' do
        let(:time) { Time.now.localtime }
        let(:entry_group) { create(:entry_group, :with_entries, time: time) }

        it 'delets the entry group file' do
          entry_group.entries = []
          expect { entry_group_write }.to_not raise_error
          expect(entry_group.exist?).to be false
        end
      end

      context 'when the entry group file does not exist and there are no entries' do
        let(:time) { Time.now.localtime }
        let(:entry_group) { build(:entry_group, :with_entries, time: time) }

        it 'raises an error and does not write the entry group file to disk' do
          entry_group.entries = []
          expect { entry_group_write }.to raise_error(/File .+ does not exist/)
          expect(entry_group.exist?).to be false
        end
      end
    end
  end
end
