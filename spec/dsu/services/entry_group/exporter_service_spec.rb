# frozen_string_literal: true

RSpec.describe Dsu::Services::EntryGroup::ExporterService do
  subject(:service) { described_class.new(entry_groups: entry_groups, options: options) }

  shared_examples 'an entry_groups argument error is raised' do
    let(:expected_error) { 'Argument entry_groups is blank' }

    it_behaves_like 'an error is raised'
  end

  let(:times) { times_for_week_of(Time.now.localtime) }
  let(:entry_groups) { nil }
  let(:options) { {} }

  describe '#initialize' do
    context 'when argument :entry_groups is nil' do
      let(:entry_groups) { nil }

      it_behaves_like 'an entry_groups argument error is raised'
    end

    context 'when argument :entry_groups is empty' do
      let(:entry_groups) { [] }

      it_behaves_like 'an entry_groups argument error is raised'
    end
  end

  describe '#call' do
    context 'when all of the entry groups exist' do
      let(:time_min) { times.min }
      let(:time_max) { times.max }
      let(:entry_groups) do
        entry_group_1_entries = build(:entry, description: 'entry_group_1_entry_1')
        entry_group_2_entries = build(:entry, description: 'entry_group_2_entry_1')
        [
          create(:entry_group, entries: [entry_group_1_entries], time: time_min),
          create(:entry_group, entries: [entry_group_2_entries], time: time_max)
        ]
      end

      it do
        expect(File.exist?(service.call)).to be true
      end

      it 'exports a CSV file with all of the entry groups'
    end

    context 'when all of the entry groups do not exist' do
      it 'exports a CSV file with only the existing entry groups'
    end
  end
end
