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
  it 'creates the entry group file if necessary' do
    expect(entry_group_file_exists?(time: time)).to be true
  end

  it 'writes the entry group to the entry group file' do
    expect(entry_group_file_matches?(time: time, entry_group_hash: entry_group.to_h)).to be true
  end
end

RSpec.describe Dsu::Services::EntryGroupWriterService do
  subject(:entry_group_writer_service) { described_class.new(entry_group: entry_group, options: options) }

  let(:entry_group) { build(:entry_group, time: time, entries: entries) }
  let(:time) { Time.now }
  let(:entries) { [] }
  let(:options) { {} }

  before do
    delete_entry_group_file!(time: time)
  end

  describe '#initialize' do
    context 'when the arguments are valid' do
      it_behaves_like 'no error is raised'
    end

    context 'when the arguments are invalid' do
      context 'when entry_group is nil' do
        let(:entry_group) { nil }
        let(:expected_error) { /entry_group is nil/ }

        it_behaves_like 'an error is raised'
      end

      context 'when entry_group is the wrong type' do
        let(:entry_group) { :invalid }
        let(:expected_error) { /entry_group is the wrong object type/ }

        it_behaves_like 'an error is raised'
      end

      context 'when options is nil' do
        let(:options) { nil }
        let(:expected_error) { /options is nil/ }

        it_behaves_like 'an error is raised'
      end

      context 'when options is the wrong type' do
        let(:options) { :invalid }
        let(:expected_error) { /options is the wrong object type/ }

        it_behaves_like 'an error is raised'
      end
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
        build_list(:entry, 2)
      end

      it_behaves_like 'the entry group has entries'
      it_behaves_like 'the entry group file is written'
    end

    context 'when updating existing entries' do
      before do
        entry_group_writer_service
        entry_group.entries.each_with_index do |entry, index|
          entry.description = "Updated description #{index}"
        end
        described_class.new(entry_group: entry_group, options: options).call
      end

      let(:entries) do
        [
          build(:entry, description: 'description 0'),
          build(:entry, description: 'description 1')
        ]
      end

      it_behaves_like 'the entry group has entries'
      it_behaves_like 'the entry group file is written'
    end

    context 'when there are entries with non-unique descriptions' do
      let(:entries) do
        build_list(:entry, 2, description: 'Non-unique description')
      end
      let(:expected_error) { /Entries entry contains a duplicate entry/ }

      it_behaves_like 'the entry group has entries'
      it_behaves_like 'an error is raised'
    end
  end
end
