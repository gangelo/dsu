# frozen_string_literal: true

RSpec.describe Dsu::Services::EntryGroup::ExporterService do
  subject(:service) { described_class.new(project_name: project_name, entry_groups: entry_groups, options: options) }

  shared_examples 'an entry_groups argument error is raised' do
    it_behaves_like 'an error is raised'
  end

  let(:times) { times_for_week_of(Time.now.localtime) }
  let(:project_name) { 'Project name' }
  let(:entry_groups) { nil }
  let(:options) { {} }

  describe '#initialize' do
    context 'when argument :entry_groups is nil' do
      let(:entry_groups) { nil }
      let(:expected_error) { 'Argument entry_groups is blank' }

      it_behaves_like 'an entry_groups argument error is raised'
    end

    context 'when argument :entry_groups is an empty Array' do
      let(:entry_groups) { [] }
      let(:expected_error) { 'Argument entry_groups is blank' }

      it_behaves_like 'an entry_groups argument error is raised'
    end

    context 'when argument :entry_groups does not pass validation' do
      before do
        entry_groups[0].time = nil
      end

      let(:entry_groups) { [create(:entry_group, :with_entries)] }
      let(:expected_error) { 'Argument entry_groups are not all valid' }

      it_behaves_like 'an entry_groups argument error is raised'
    end

    context 'when argument :entry_groups has no entries' do
      let(:entry_groups) { [create(:entry_group, time: times.min)] }
      let(:expected_error) do
        "Argument entry_groups entry group for #{entry_groups[0].time_yyyy_mm_dd} has no entries"
      end

      it_behaves_like 'an entry_groups argument error is raised'
    end
  end

  describe '#call' do
    let(:entry_groups) do
      entry_group_1_entries = build(:entry, description: 'entry_group_1_entry_1')
      entry_group_2_entries = build(:entry, description: 'entry_group_2_entry_1')
      [
        create(:entry_group, entries: [entry_group_1_entries], time: times.min),
        create(:entry_group, entries: [entry_group_2_entries], time: times.max)
      ]
    end
    let(:expected_csv_contents) do
      <<~CSV
        project_name,version,entry_group,entry_no,total_entries,entry_group_entry
        #{project_name},#{entry_groups[0].version},#{entry_groups[0].time_yyyy_mm_dd},1,1,#{entry_groups[0].entries[0].description}
        #{project_name},#{entry_groups[1].version},#{entry_groups[1].time_yyyy_mm_dd},1,1,#{entry_groups[1].entries[0].description}
      CSV
    end

    it do
      expect(File.exist?(service.call)).to be true
    end

    it 'exports a CSV file with all of the entry groups' do
      expect(File.read(service.call)).to eq(expected_csv_contents)
    end
  end
end
