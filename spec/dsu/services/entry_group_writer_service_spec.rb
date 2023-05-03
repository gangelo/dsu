# frozen_string_literal: true

RSpec.shared_examples 'the entry group has entries' do
  it 'has entries' do
    expect(entry_group.entries).not_to be_empty
  end
end

RSpec.shared_examples 'the entry group has no entries' do
  it 'has no entries' do
    expect(entry_group.entries).to be_empty
  end
end

RSpec.shared_examples 'the entry group file is written' do
  it 'writes the entry group to the entry group file' do
    expect(entry_group_file_exists?(time: time)).to be true
    expect(entry_group_file_matches?(time: time, entry_group_hash: entry_group.to_h)).to be true
  end
end

RSpec.describe Dsu::Services::EntryGroupWriterService do
  subject(:entry_group_writer_service) { described_class.new(entry_group: entry_group, options: options) }

  let(:entry_group) { build(:entry_group, time: time, entries: entries) }
  let(:time) { Time.now }
  let(:entries) { [] }
  let(:options) { nil }

  before do
    delete_entry_group_file!(time: time.utc)
  end

  describe '#initialize' do
    context 'when the arguments are valid' do
      it_behaves_like 'no error is raised'
    end

    # No errors are expected because the arguments are not
    # evaluated until #call is invoked.
    context 'when the arguments are invalid' do
      let(:entry_group) { 'invalid' }
      let(:options) { 'invalid' }

      it_behaves_like 'no error is raised'
    end
  end

  describe '#call' do
    subject(:entry_group_writer_service) { described_class.new(entry_group: entry_group, options: options).call }

    context 'when there are no entries' do
      before do
        entry_group_writer_service
      end

      it_behaves_like 'the entry group has no entries'
      it_behaves_like 'the entry group file is written'
    end

    context 'when adding new entries' do
      before do
        entry_group_writer_service
      end

      let(:entries) do
        [
          build(:entry, time: time, uuid: '01234567'),
          build(:entry, time: time, uuid: '89abcdef')
        ]
      end

      it_behaves_like 'the entry group has entries'
      it_behaves_like 'the entry group file is written'
    end

    context 'when updating existing entries' do
      before do
        entry_group_writer_service
        entry_group.entries.each_with_index do |entry, index|
          entry.description = "Updated description #{index}"
          entry.long_description = "Updated long description #{index}"
          #entry_group.entries[index] = Dsu::Support::Entry.new **entry
        end
        described_class.new(entry_group: entry_group, options: options).call
      end

      let(:entries) do
        [
          build(:entry, time: time, uuid: '01234567', description: 'description 0', long_description: 'long description 0'),
          build(:entry, time: time, uuid: '89abcdef', description: 'description 1', long_description: 'long description 1')
        ]
      end

      it_behaves_like 'the entry group has entries'
      it_behaves_like 'the entry group file is written'
    end

    context 'when there are entries with non-unique uuids' do
      let(:entries) do
        [
          build(:entry, time: time, uuid: '11111111'),
          build(:entry, time: time, uuid: '11111111', description: 'duplicate uuid')
        ]
      end
      let(:expected_error) { /Entries contains duplicate UUIDs/ }

      it_behaves_like 'the entry group has entries'
      it_behaves_like 'an error is raised'
    end
  end
end
