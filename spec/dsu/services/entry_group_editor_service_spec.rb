# frozen_string_literal: true

RSpec.describe Dsu::Services::EntryGroupEditorService do
  subject(:entry_group_editor_service) { described_class.new(entry_group: entry_group) }

  include_context 'with tmp'

  let(:time) { entry_group.time }
  let(:entry_group) { build(:entry_group, time: Time.now, entries: build_list(:entry, 2)) }
  let!(:original_entry_group) { entry_group.clone }

  describe '#initialize' do
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
    before do
      allow(Dsu::Services::StdoutRedirectorService).to receive(:call).and_return(tmp_file_contents)
      editor = Dsu::Support::Configuration::DEFAULT_DSU_OPTIONS['editor']
      allow(Kernel).to receive(:system).with("${EDITOR:-#{editor}} #{tmp_file.path}").and_return(true)
    end

    context 'when the editing session fails' do
      before do
        editor = Dsu::Support::Configuration::DEFAULT_DSU_OPTIONS['editor']
        allow(Kernel).to receive(:system).with("${EDITOR:-#{editor}} #{tmp_file.path}").and_return(false)
      end

      let(:tmp_file_contents) { '' }

      it 'displays an error in the console' do
        expect do
          entry_group_editor_service.call
        end.to output(/Failed to open temporary file in editor/).to_stdout
      end
    end

    context 'when there are no changes' do
      before do
        entry_group_editor_service.call
      end

      let(:tmp_file_contents) do
        Dsu::Views::EntryGroup::Edit.new(entry_group: original_entry_group).render_as_string
      end

      it 'does not change the entry_group object' do
        expect(entry_group.to_h).to match(original_entry_group.to_h)
      end

      it 'does not change the entry group file' do
        expect(entry_group_file_matches?(time: time, entry_group_hash: entry_group.to_h)).to be true
      end
    end

    context 'when the entry descriptions change' do
      before do
        entry_group_editor_service.call
      end

      let(:tmp_file_contents) do
        Dsu::Views::EntryGroup::Edit.new(entry_group: changed_entry_group).render_as_string
      end
      let(:changed_entry_group) do
        original_entry_group.clone.tap do |cloned_entry_group|
          cloned_entry_group.entries = build_list(:entry, 2)
        end
      end

      it 'saves the changes to the entry_group object' do
        expect(entry_group.to_h).to match(changed_entry_group.to_h)
      end

      it 'saves the changes to the entry group file' do
        expect(entry_group_file_matches?(time: time, entry_group_hash: entry_group.to_h)).to be true
      end

      it 'does not change the original time' do
        expect(entry_group.time).to match(changed_entry_group.time)
      end
    end

    context 'when an entry is deleted' do
      before do
        entry_group_editor_service.call
      end

      let(:tmp_file_contents) do
        Dsu::Views::EntryGroup::Edit.new(entry_group: changed_entry_group).render_as_string
      end
      let(:changed_entry_group) do
        original_entry_group.clone.tap do |cloned_entry_group|
          # Delete the last entry.
          cloned_entry_group.entries.pop
        end
      end

      it 'deletes the entry from the entry group object' do
        expect(entry_group.entries.count).to eq(1)
      end

      it 'saves the changes to the entry group object' do
        expect(entry_group.to_h).to match(changed_entry_group.to_h)
      end

      it 'saves the changes to the entry group file' do
        expect(entry_group_file_matches?(time: time, entry_group_hash: entry_group.to_h)).to be true
      end
    end

    context 'when all the entries are deleted' do
      before do
        entry_group_editor_service.call
      end

      let(:tmp_file_contents) do
        Dsu::Views::EntryGroup::Edit.new(entry_group: changed_entry_group).render_as_string
      end
      let(:changed_entry_group) do
        original_entry_group.clone.tap do |cloned_entry_group|
          cloned_entry_group.entries = []
        end
      end

      it 'deletes the entries from the entry group object' do
        expect(entry_group.entries.count).to be_zero
      end

      it 'does not change the entry group time' do
        expect(entry_group.time).to eq(original_entry_group.time)
      end

      it 'deletes the entry group file' do
        expect(entry_group_file_exists?(time: original_entry_group.time)).to be false
      end
    end

    context 'when entries are added' do
      before do
        entry_group_editor_service.call
      end

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

      it 'adds the entries to the entry group object' do
        expect(entry_group.entries.map(&:description)).to match_array(changed_entry_group.entries.map(&:description))
      end

      it 'does not change the entry group time' do
        expect(entry_group.time).to eq(original_entry_group.time)
      end

      it 'saves the changes to the entry group file' do
        expect(entry_group_file_matches?(time: time, entry_group_hash: changed_entry_group.to_h)).to be true
      end
    end

    context 'when the entry group file is edited incorrectly' do
      context 'when the entry group fails validation' do
        let(:tmp_file_contents) do
          # This simply simulates the user making entry group entry changes in the console.
          # For example, deleting everything the editor initially displays, and the user
          # entering the below entry descriptions which is a valid scenario.
          changed_entry_group.entries.map(&:description).join("\n")
        end
        let(:changed_entry_group) do
          entry_group.clone.tap do |cloned_entry_group|
            cloned_entry_group.entries << build(:entry, description: 'Duplicate description')
            cloned_entry_group.entries << build(:entry, description: 'Duplicate description')
          end
        end

        it 'displays the validation error in the console' do
          expect do
            entry_group_editor_service.call
          end.to output(/The following ERRORS were encountered/).to_stdout
        end


        it 'saves all the valid entries to the entry group file and ignores the invalid entries'
      end
    end
  end
end
