# frozen_string_literal: true

RSpec.shared_examples 'the entry is ignored and not saved' do
  it 'does something'
end

RSpec.describe Dsu::Services::EntryGroupEditorService do
  subject(:entry_group_editor_service) { described_class.new(entry_group: entry_group) }

  include_context 'with tmp'

  let(:time) { Time.now }
  let(:entry_group) { build(:entry_group, entries: build_list(:entry, 2)) }
  let!(:original_entry_group_hash) { entry_group.try(:to_h) || {} }

  describe '#initializer' do
    context 'when the arguments are valid' do
      it 'does not raise an error' do
        expect { entry_group_editor_service }.not_to raise_error
      end
    end

    context 'when entry_group is nil' do
      let(:entry_group) { nil }
      let(:expected_error) { /entry_group is nil/ }

      it_behaves_like 'an error is raised'
    end

    context 'when entry_group is not an EntryGroup' do
      let(:entry_group) { 'not an EntryGroup' }
      let(:expected_error) { /entry_group is the wrong object type/ }

      it_behaves_like 'an error is raised'
    end

    context 'when options is nil' do
      let(:options) { nil }

      it_behaves_like 'no error is raised'
    end

    context 'when options is not a Hash' do
      subject(:entry_group_editor_service) { described_class.new(entry_group: entry_group, options: 'not a Hash') }

      let(:expected_error) { /options is the wrong object type/ }

      it_behaves_like 'an error is raised'
    end
  end

  describe '#call' do
    subject(:entry_group_editor_service_call) { entry_group_editor_service.call }

    before do
      allow(Dsu::Services::TempFileWriterService).to receive(:tmp_file_contents).and_return(tmp_file_contents)
      editor = Dsu::Support::Configuration::DEFAULT_DSU_OPTIONS['editor']
      allow(Kernel).to receive(:system).with("${EDITOR:-#{editor}} #{tmp_file.path}").and_return(true)
      entry_group_editor_service_call
    end

    context 'when there are no changes' do
      let(:tmp_file_contents) do
        # Just render the original entry group unchanged, because we went
        # to test for no changes.
        Dsu::Views::EntryGroup::Edit.new(entry_group: entry_group).render
      end
      let(:expected_changes) { entry_group.entries.map(&:description) }

      it 'does not change the entry_group object' do
        expect(entry_group.to_h).to match(original_entry_group_hash)
      end

      it 'does not change the entry group file' do
        expect(entry_group_file_matches?(time: time, entry_group_hash: original_entry_group_hash)).to be true
      end
    end

    context 'when the entry descriptions change' do
      let(:tmp_file_contents) do
        Dsu::Views::EntryGroup::Edit.new(entry_group:
          entry_group.clone.tap do |cloned_entry_group|
            cloned_entry_group.entries.each_with_index do |entry, index|
              cloned_entry_group.entries[index] = entry.clone
              cloned_entry_group.entries[index].description = "Changed description #{index}"
            end
          end).render
      end
      let(:expected_changes) do
        [
          'Changed description 0',
          'Changed description 1'
        ]
      end

      it 'saves the changes to the entry_group object' do
        expect(entry_group.entries.map(&:description)).to match_array(expected_changes)
      end

      it 'saves the changes to the entry group file' do
        expect(entry_group_file_matches?(time: time, entry_group_hash: entry_group.to_h)).to be true
      end

      it 'does not change the original time' do
        expect(entry_group.to_h).to match(original_entry_group_hash)
      end
    end

    context 'when an entry is deleted' do
      let(:tmp_file_contents) do
        Dsu::Views::EntryGroup::Edit.new(entry_group:
          entry_group.clone.tap do |cloned_entry_group|
            cloned_entry_group.entries.each_with_index do |entry, index|
              cloned_entry_group.entries[index] = entry.clone
            end
            # Delete the last entry.
            cloned_entry_group.entries.pop
          end).render
      end

      it 'deletes the entry from the entry group object' do
        expect(entry_group.entries.count).to eq(1)
      end

      it 'saves the changes to the entry group object' do
        expect(entry_group.to_h[:entries].first).to eq(original_entry_group_hash[:entries].first)
      end

      it 'does not change the original entry group time or entry descriptions' do
        # TODO: Do I need to clone and remove the the original entry group hash?
        expect(entry_group.to_h).to match(original_entry_group_hash)
      end

      it 'saves the changes to the entry group file' do
        expect(entry_group_file_matches?(time: time, entry_group_hash: entry_group.to_h)).to be true
      end
    end

    context 'when all the entries are deleted' do
      let(:entry_group) { build(:entry_group, entries: build_list(:entry, delete_cmds.length)) }
      let(:entry_group_hash) { entry_group.to_h }
      let(:tmp_file_contents) do
        Dsu::Views::EntryGroup::Edit.new(entry_group:
          entry_group.clone.tap do |cloned_entry_group|
            cloned_entry_group.entries = []
          end).render
      end

      it 'deletes the entries from the entry group object' do
        expect(entry_group.entries.count).to be_zero
      end

      it 'does not change the entry group time' do
        expect(entry_group_hash[:time]).to eq(original_entry_group_hash[:time])
      end

      it 'deletes the entry group file' do
        expect(entry_group_file_exists?(time: time)).to be false
      end
    end

    context 'when entries are added' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:tmp_file_contents) do
        entry_group_clone = entry_group.clone
        entry_group_clone.entries.concat(added_entries)
        Dsu::Views::EntryGroup::Edit.new(entry_group: entry_group_clone).render
      end
      let(:added_entries) do
        [
          build(:entry, description: 'Added entry 1'),
          build(:entry, description: 'Added entry 2')
        ]
      end

      it 'adds the entries to the entry group object' do
        entries_count = added_entries.count + original_entry_group_hash[:entries].count
        expect(entry_group.entries.count).to eq(entries_count)
      end

      it 'does not change the entry group time' do
        expect(entry_group.time).to eq(original_entry_group_hash[:time])
      end

      it 'saves the changes to the entry group file' do
        expect(entry_group_file_matches?(time: time, entry_group_hash: entry_group.to_h)).to be true
      end
    end

    context 'when the entry group file is edited incorrectly' do
      before do
        allow(Dsu::Views::EntryGroup::Edit).to receive(:entry_group_entry_lines).and_return(edit_entry_groups)
      end

      context 'when then entry line has no sha or editor command' do
        let(:edit_entry_groups) do
          [
            'This is an entry with no sha or editor command'
          ]
        end

        it_behaves_like 'the entry is ignored and not saved'
      end
    end
  end
end
