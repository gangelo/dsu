# frozen_string_literal: true

RSpec.describe Dsu::Services::EntryGroup::BrowseService do
  subject(:service) { described_class.new(time: time, options: options) }

  let(:time) { Time.now }
  let(:options) { { browse: :week } }

  describe '#initialize' do
    context 'when argument :time is nil' do
      let(:time) { nil }
      let(:expected_error) { 'Argument time is nil' }

      it_behaves_like 'an error is raised'
    end

    context 'when argument :options is nil' do
      let(:options) { nil }
      let(:expected_error) { 'Argument options is nil' }

      it_behaves_like 'an error is raised'
    end
  end

  describe '#call' do
    context 'when option :include_all is true' do
      before do
        options.merge!({ include_all: true })
      end

      context 'when there are no entry groups with entries' do
        it 'returns an array of times that have no entry groups' do
          expected_times = times_for_week_of(time)
          expect(service.call).to match_array(expected_times)
        end
      end

      context 'when there are entry groups with entries' do
        before do
          create(:entry_group, :with_entries, time: time.beginning_of_week)
          create(:entry_group, :with_entries, time: time.end_of_week)
        end

        it 'returns an array of times that have no entry groups and times that have entry groups' do
          expected_times = times_for_week_of(time)
          expect(service.call).to match_array(expected_times)
        end
      end
    end

    context 'when option :include_all is false' do
      before do
        options.merge!({ include_all: false })
      end

      context 'when there are no entry groups with entries' do
        it 'returns an empty array' do
          expect(service.call).to eq([])
        end
      end

      context 'when there are entry groups with entries' do
        let!(:entry_groups) do
          [
            create(:entry_group, :with_entries, time: time.beginning_of_week),
            create(:entry_group, :with_entries, time: time.end_of_week)
          ]
        end

        it 'returns an array of times that only have entry groups' do
          expected_times = [
            entry_groups[0].time.beginning_of_day,
            entry_groups[1].time.beginning_of_day
          ]
          expect(service.call).to match_array(expected_times)
        end
      end
    end

    context 'when option :entries_display_order is :asc' do
      before do
        options.merge!({ entries_display_order: :asc })
      end

      let!(:entry_groups) do
        [
          create(:entry_group, :with_entries, time: time.beginning_of_week),
          create(:entry_group, :with_entries, time: time.end_of_week)
        ]
      end

      it 'returns the entry group times in ascending order' do
        expected_times = [
          entry_groups[0].time.beginning_of_day,
          entry_groups[1].time.beginning_of_day
        ]
        expect(service.call).to match_array(expected_times)
      end
    end

    context 'when option :entries_display_order is :desc' do
      before do
        options.merge!({ entries_display_order: :desc })
      end

      let!(:entry_groups) do
        [
          create(:entry_group, :with_entries, time: time.beginning_of_week),
          create(:entry_group, :with_entries, time: time.end_of_week)
        ]
      end

      it 'returns the entry group times in descending order' do
        expected_times = [
          entry_groups[1].time.beginning_of_day,
          entry_groups[0].time.beginning_of_day
        ]
        expect(service.call).to match_array(expected_times)
      end
    end
  end
end
