# frozen_string_literal: true

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

      it_behaves_like 'the entry group file is written'
    end

    context 'when there are entries' do
      before do
        entry_group_writer_service
      end

      let(:entries) do
        [
          build(:entry, time: time, uuid: '01234567'),
          build(:entry, time: time, uuid: '89abcdef')
        ]
      end

      it_behaves_like 'the entry group file is written'
    end

    xcontext 'when the entries are invalid' do
      let(:entry_group) do
        build(:entry_group).tap do |entry_group|
          entry_group.entries = :invalid
        end
      end

      it_behaves_like 'no error is raised'
    end

    xcontext 'when the entry group is not written' do
      let(:entry_group) { 'invalid' }
      let(:expected_error) { ActiveModel::ValidationError }

      it_behaves_like 'an error is raised'
    end

    xcontext 'when the entry group is written' do
      before do
        entry_group_writer_service
      end

      it 'returns the entry group' do
        expect(entry_group_writer_service).to eq entry_group
      end

      it 'writes the entry group to the entries file' do
        Dsu::Support::EntryGroup.new(time: entry_group.time).tap do |entry_group|
          expect(entry_group[:entries]).to eq entries
        end
      end
    end
  end
end
