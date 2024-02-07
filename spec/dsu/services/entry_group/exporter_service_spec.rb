# frozen_string_literal: true

RSpec.describe Dsu::Services::EntryGroup::ExporterService do
  subject(:service) { described_class.new(project_name: project_name, entry_groups: entry_groups, options: options) }

  shared_examples 'an entry_groups argument error is raised' do
    it_behaves_like 'an error is raised'
  end

  let(:options) { {} }
  let(:time) { Time.now.localtime }
  let(:times) { times_for_week_of(time) }
  let(:project_name) { 'Project name' }
  let(:entry_groups) { nil }

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
    shared_examples 'an exported entry group file is created' do
      let(:expected_csv_contents) do
        csv_contents = []
        csv_contents << 'project_name,version,entry_group,entry_no,total_entries,entry_group_entry'
        csv_contents << times.each_with_index.map do |_time, entry_group_index|
          total_entries = entry_groups[entry_group_index].entries.count
          entry_groups[entry_group_index].entries.each_with_index.map do |_entry, entry_index|
            "#{project_name},#{entry_groups[entry_group_index].version},#{entry_groups[entry_group_index].time_yyyy_mm_dd},#{entry_index + 1},#{total_entries},#{entry_groups[entry_group_index].entries[entry_index].description}"
          end
        end
        csv_contents.flatten.join("\n")
      end

      it do
        expect(File.exist?(service.call)).to be true
      end

      it 'exports a CSV file with all of the entry groups' do
        expect(File.read(service.call).chomp).to eq(expected_csv_contents)
      end
    end

    let(:entry_groups) do
      times.map do |time|
        entries = []
        entries << build(:entry, description: "entry_group_#{time.to_date}_entry_1")
        entries << build(:entry, description: "entry_group_#{time.to_date}_entry_2")
        create(:entry_group, time: time, entries: entries)
      end
    end

    context 'when exporting all entry groups' do
      it_behaves_like 'an exported entry group file is created'

      it 'produces an export file name name with the exported dates' do
        expect(service.call).to include("all-entry-groups-#{times.min.to_date}-thru-#{times.max.to_date}.csv")
      end
    end

    context 'when exporting time-filtered entry groups' do
      let(:options) { { times: times } }
      let(:times) { times_for_week_of(time)[1..-2] }

      it_behaves_like 'an exported entry group file is created'

      it 'produces an export file name name with the exported dates' do
        expect(service.call).to include("entry-groups-#{times.min.to_date}-thru-#{times.max.to_date}.csv")
      end
    end
  end
end
