# frozen_string_literal: true

RSpec.describe 'Dsu browse features', type: :feature do
  subject(:cli) do
    strip_escapes(Dsu::Services::StdoutRedirectorService.call { Dsu::CLI.start(args) })
  end

  shared_examples 'help is displayed' do
    it 'displays help' do
      expect(cli).to include('rspec browse help [COMMAND]')
    end
  end

  before do
    freeze_time_at(time_string: time_string)
  end

  let(:time_string) { '2023-06-12' }
  let(:configuration) do
    build(:configuration)
  end

  context "when 'dsu help browse' is used" do
    let(:args) { %w[help browse] }

    it_behaves_like 'help is displayed'
  end

  context "when 'dsu browse COMMAND' is used" do
    context 'with no COMMAND argument' do
      let(:args) { %w[browse] }

      it_behaves_like 'help is displayed'
    end

    context 'with a mnemonic' do
      context "with 'week'" do
        before do
          entry_groups
        end

        let(:args) { %w[browse week --pager false] }
        let(:time_string) { '2023-01-01' }
        let(:entry_groups) do
          times_for_week_of(Time.parse(time_string)).each.map do |time|
            entries = [
              build(:entry, description: "#{to_yyyymmdd_string(time)} Entry 1"),
              build(:entry, description: "#{to_yyyymmdd_string(time)} Entry 2")
            ]
            create(:entry_group, time: time, entries: entries)
          end
        end

        it 'displays the entry groups for the week' do
          entry_groups.each do |entry_group|
            entry_group_header = Dsu::Support::TimeFormatable.formatted_time(time: entry_group.time)
            expect(cli).to include(entry_group_header).and include(entry_group.entries[0].description).and include(entry_group.entries[1].description)
          end
        end
      end

      context "with 'month'" do
        before do
          entry_groups
        end

        let(:args) { %w[browse month --pager false] }
        let(:time_string) { '2023-01-01' }
        let(:entry_groups) do
          times_for_month_of(Time.parse(time_string)).each.map do |time|
            entries = [
              build(:entry, description: "#{to_yyyymmdd_string(time)} Entry 1"),
              build(:entry, description: "#{to_yyyymmdd_string(time)} Entry 2")
            ]
            create(:entry_group, time: time, entries: entries)
          end
        end

        it 'displays the entry groups for the month' do
          entry_groups.each do |entry_group|
            entry_group_header = Dsu::Support::TimeFormatable.formatted_time(time: entry_group.time)
            expect(cli).to include(entry_group_header).and include(entry_group.entries[0].description).and include(entry_group.entries[1].description)
          end
        end
      end

      context "with 'year'" do
        before do
          entry_groups
        end

        let(:args) { %w[browse year --pager false] }
        let(:time_string) { '2023-01-01' }
        let(:entry_groups) do
          times_for_year_of(Time.parse(time_string)).each.map do |time|
            entries = [
              build(:entry, description: "#{to_yyyymmdd_string(time)} Entry 1"),
              build(:entry, description: "#{to_yyyymmdd_string(time)} Entry 2")
            ]
            create(:entry_group, time: time, entries: entries)
          end
        end

        it 'displays the entry groups for the year' do
          entry_groups.each do |entry_group|
            entry_group_header = Dsu::Support::TimeFormatable.formatted_time(time: entry_group.time)
            expect(cli).to include(entry_group_header).and include(entry_group.entries[0].description).and include(entry_group.entries[1].description)
          end
        end
      end
    end
  end
end
