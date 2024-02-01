# frozen_string_literal: true

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Dsu::Services::EntryGroup::ImporterService do
  subject(:service) { described_class.new(import_projects: import_projects, options: options) }

  shared_examples 'an import_projects argument error is raised' do
    it_behaves_like 'an error is raised'
  end

  shared_examples 'the correct messages are returned' do
    it 'returns the correct messages' do
      expect(subject.call).to eq(expected_messages)
    end
  end

  let(:project_name) { 'Project name' }
  let(:times) { times_for_week_of(Time.now.localtime) }
  let(:options) { { merge: true } }

  describe '#initialize' do
    context 'when argument :import_projects is nil' do
      let(:import_projects) { nil }
      let(:expected_error) { 'Argument import_projects is blank' }

      it_behaves_like 'an import_projects argument error is raised'
    end

    context 'when argument :import_projects is an empty Hash' do
      let(:import_projects) { {} }
      let(:expected_error) { 'Argument import_projects is blank' }

      it_behaves_like 'an import_projects argument error is raised'
    end

    context 'when argument :import_projects has more than one project' do
      let(:import_projects) do
        {
          'Project 1': {
            '2023-01-01': ['Project 1, entry 1 decription']
          },
          'Project 2': {
            '2023-01-01': ['Project 2, entry 1 decription']
          }
        }
      end
      let(:expected_error) { 'Only one project can be imported at a time' }

      it_behaves_like 'an import_projects argument error is raised'
    end
  end

  describe '#call' do
    context 'when importing multiple entry groups that are valid and not duplicate' do
      let(:import_projects) do
        {
          project_name => {
            entry_groups[0].time_yyyy_mm_dd => [project_entry_group_entries[0].description],
            entry_groups[1].time_yyyy_mm_dd => [project_entry_group_entries[1].description]
          }
        }
      end
      let(:entry_groups) do
        [
          create(:entry_group, entries: [build(:entry, description: 'entry_group_1_entry_1')], time: times.min),
          create(:entry_group, entries: [build(:entry, description: 'entry_group_2_entry_1')], time: times.max)
        ]
      end
      let(:project_entry_group_entries) do
        [
          build(:entry, description: "imported_#{entry_groups[0].entries.first.description}"),
          build(:entry, description: "imported_#{entry_groups[1].entries.first.description}")
        ]
      end

      context 'when the project name matches the current project name' do
        before do
          create(:project, :current_project, project_name: project_name)
          service.call
        end

        let(:expected_messages) do
          {
            entry_groups[0].time_yyyy_mm_dd => [],
            entry_groups[1].time_yyyy_mm_dd => []
          }
        end

        it 'imports the first entry group and all of the entries' do
          expected_entry_group = entry_groups[0].clone
          expected_entry_group.entries << project_entry_group_entries[0].clone
          expect(Dsu::Models::EntryGroup.find(time: times.min) == expected_entry_group).to be true
        end

        it 'imports the rest of the entry groups and all of their entries' do
          expected_entry_group = entry_groups[1].clone
          expected_entry_group.entries << project_entry_group_entries[1].clone
          expect(Dsu::Models::EntryGroup.find(time: times.max) == expected_entry_group).to be true
        end

        it_behaves_like 'the correct messages are returned'
      end
    end

    context 'when importing multiple entry groups with duplicate entries' do
      before do
        create(:project, :current_project, project_name: project_name)
        service.call
      end

      let(:import_projects) do
        {
          project_name => {
            entry_groups[0].time_yyyy_mm_dd => [project_entry_group_entries[0].description],
            entry_groups[1].time_yyyy_mm_dd => [project_entry_group_entries[1].description]
          }
        }
      end
      let(:entry_groups) do
        [
          create(:entry_group, entries: [build(:entry, description: 'entry_group_1_entry_1')], time: times.min),
          create(:entry_group, entries: [build(:entry, description: 'entry_group_2_entry_1')], time: times.max)
        ]
      end
      let(:project_entry_group_entries) do
        [
          entry_groups[0].entries.first.clone,
          entry_groups[1].entries.first.clone
        ]
      end

      context 'when option :merge is true' do
        let(:options) { { merge: true } }
        let(:expected_messages) do
          {
            entry_groups[0].time_yyyy_mm_dd => [],
            entry_groups[1].time_yyyy_mm_dd => []
          }
        end

        it 'does not import the first entry group' do
          expected_entry_group = entry_groups[0].clone
          expect(Dsu::Models::EntryGroup.find(time: times.min) == expected_entry_group).to be true
        end

        it 'does not import the rest of the entry groups or their entries' do
          expected_entry_group = entry_groups[1].clone
          expect(Dsu::Models::EntryGroup.find(time: times.max) == expected_entry_group).to be true
        end

        it_behaves_like 'the correct messages are returned'
      end

      context 'when option :merge is false' do
        let(:options) { { merge: false } }

        it 'imports the first entry group and replaces all of the entries' do
          expected_entry_group = entry_groups[0].clone
          expected_entry_group.entries = [project_entry_group_entries[0].clone]
          expect(Dsu::Models::EntryGroup.find(time: times.min) == expected_entry_group).to be true
        end

        it 'imports the rest of the entry groups and replaces all of their entries' do
          expected_entry_group = entry_groups[1].clone
          expected_entry_group.entries = [project_entry_group_entries[1].clone]
          expect(Dsu::Models::EntryGroup.find(time: times.max) == expected_entry_group).to be true
        end

        it 'returns a Hash of empty error messages' do
          expected_messages = {
            entry_groups[0].time_yyyy_mm_dd => [],
            entry_groups[1].time_yyyy_mm_dd => []
          }
          expect(service.call).to eq(expected_messages)
        end
      end
    end

    context 'when importing multiple entry groups with invalid entries' do
      before do
        create(:project, :current_project, project_name: project_name)
        service.call
      end

      let(:import_projects) do
        {
          project_name => {
            entry_groups[0].time_yyyy_mm_dd => [project_entry_group_entries[0].description],
            entry_groups[1].time_yyyy_mm_dd => [project_entry_group_entries[1].description]
          }
        }
      end
      let(:entry_groups) do
        [
          create(:entry_group, entries: [build(:entry, description: 'entry_group_1_entry_1')], time: times.min),
          create(:entry_group, entries: [build(:entry, description: 'entry_group_2_entry_1')], time: times.max)
        ]
      end
      let(:project_entry_group_entries) do
        [
          build(:entry, description: "imported_#{entry_groups[0].entries.first.description}_#{'x' * Dsu::Models::Entry::MAX_DESCRIPTION_LENGTH}"),
          build(:entry, description: "imported_#{entry_groups[1].entries.first.description}_#{'y' * Dsu::Models::Entry::MAX_DESCRIPTION_LENGTH}")
        ]
      end

      context 'when option :merge is true' do
        let(:options) { { merge: true } }
        let(:expected_messages) do
          {
            entry_groups[0].time_yyyy_mm_dd => ['Entries entry Description is too long: "imported_entry_group_1..." (maximum is 256 characters).'],
            entry_groups[1].time_yyyy_mm_dd => ['Entries entry Description is too long: "imported_entry_group_2..." (maximum is 256 characters).']
          }
        end

        it 'does not import the first entry group entries that are invalid' do
          expected_entry_group = entry_groups[0].clone
          expect(Dsu::Models::EntryGroup.find(time: times.min) == expected_entry_group).to be true
        end

        it 'does not import the rest of the entry group entries that are invalid' do
          expected_entry_group = entry_groups[1].clone
          expect(Dsu::Models::EntryGroup.find(time: times.max) == expected_entry_group).to be true
        end

        it_behaves_like 'the correct messages are returned'
      end
    end

    context 'when importing a project that is not the current project' do
      before do
        default_project.use!
        import_projects
      end

      let(:import_projects) do
        {
          current_project.project_name => {
            to_yyyymmdd_string(entry_groups[0].time) => [project_entry_group_entries[0].description],
            to_yyyymmdd_string(entry_groups[1].time) => [project_entry_group_entries[1].description]
          }
        }
      end
      let(:entry_groups) do
        [
          create(:entry_group, entries: [build(:entry, description: 'entry_group_1_entry_1')], time: times.min),
          create(:entry_group, entries: [build(:entry, description: 'entry_group_2_entry_1')], time: times.max)
        ]
      end
      let(:project_entry_group_entries) do
        [
          build(:entry, description: entry_groups[0].entries.first.description),
          build(:entry, description: entry_groups[1].entries.first.description)
        ]
      end

      context 'when the override option is true' do
        before do
          options[:override] = true
          create(:project, :current_project, project_name: project_name)
          service.call
        end

        let(:expected_messages) do
          {
            to_yyyymmdd_string(times.min, include_timezone: false) => [],
            to_yyyymmdd_string(times.max, include_timezone: false) => []
          }
        end

        it 'is using the correct project' do
          expect(current_project.project_name).to eq(project_name)
        end

        it 'imports the entry groups and all of the entries into the current project' do
          expect(Dsu::Models::EntryGroup.find(time: times.min).entries.map(&:description)).to match_array(entry_groups[0].entries.map(&:description))
          expect(Dsu::Models::EntryGroup.find(time: times.max).entries.map(&:description)).to match_array(entry_groups[1].entries.map(&:description))
        end

        it_behaves_like 'the correct messages are returned'
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
