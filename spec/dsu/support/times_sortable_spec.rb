# frozen_string_literal: true

RSpec.describe Dsu::Support::TimesSortable do
  subject(:times_sortable) { described_class }

  let(:time) { Time.now }
  let(:times) { [time.yesterday, time, time.tomorrow] }
  let(:entries_display_order) { 'asc' }

  describe '.times_sort' do
    context 'when the arguments are invalid' do
      context 'when argument :times is not an Array' do
        let(:times) { :bad }
        let(:expected_error) { /times is the wrong object type/ }

        it 'raises an error' do
          expect { times_sortable.times_sort(times: times) }.to raise_error(expected_error)
        end
      end

      context 'when argument :times is an empty Array' do
        let(:times) { [] }
        let(:expected_error) { /times is empty/ }

        it 'raises an error' do
          expect { times_sortable.times_sort(times: times) }.to raise_error(expected_error)
        end
      end

      context 'when argument :entries_display_order is not a String' do
        let(:entries_display_order) { :bad }
        let(:expected_error) { /entries_display_order is the wrong object type/ }

        it 'raises an error' do
          expect { times_sortable.times_sort(times: times, entries_display_order: entries_display_order) }.to raise_error(expected_error)
        end
      end

      context 'when argument :entries_display_order is not a valid sort order' do
        let(:entries_display_order) { 'sideways' }
        let(:expected_error) { /entries_display_order is invalid/ }

        it 'raises an error' do
          expect { times_sortable.times_sort(times: times, entries_display_order: entries_display_order) }.to raise_error(expected_error)
        end
      end
    end

    context 'when the arguments are valid' do
      context 'when argument :entries_display_order is nil' do
        it 'defaults to asc sort and returns the times in ascending order' do
          expect(times_sortable.times_sort(times: times)).to eq times
        end
      end

      context 'when argument :entries_display_order is "asc"' do
        let(:entries_display_order) { 'asc' }

        it 'returns the times in ascending order' do
          expect(times_sortable.times_sort(times: times, entries_display_order: entries_display_order)).to eq times.sort
        end
      end

      context 'when argument :entries_display_order is "desc"' do
        let(:entries_display_order) { 'desc' }

        it 'returns the times in descending order' do
          expect(times_sortable.times_sort(times: times, entries_display_order: entries_display_order)).to eq times.reverse
        end
      end

      context 'when argument :times is an Array with one time element' do
        let(:times) { [time] }

        it 'returns the original time' do
          expect(times_sortable.times_sort(times: times)).to eq times
        end
      end
    end
  end

  describe '.times_for' do
    context 'when the arguments are invalid' do
      context 'when argument :time is not an Array' do
        let(:times) { :bad }
        let(:expected_error) { /times is the wrong object type/ }

        it 'raises an error' do
          expect { times_sortable.times_for(times: times) }.to raise_error(expected_error)
        end
      end
    end

    context 'when the arguments are valid' do
      context 'when times.max is a Monday' do
        # Monday
        let(:time) { Time.parse('2023-06-05') }
        let(:times) { [time, time.yesterday, time.yesterday.yesterday] }

        it 'is Monday' do
          expect(times.max.monday?).to be true
        end

        it 'returns last Friday through Monday' do
          expected_array = [time - 3.days, time - 2.days, time - 1.day, time]
          expect(times_sortable.times_for(times: times)).to match_array expected_array
        end
      end

      context 'when times.max is a Sunday' do
        # Sunday
        let(:time) { Time.parse('2023-06-04') }
        let(:times) { [time.yesterday, time] }

        it 'is Sunday' do
          expect(times.max.sunday?).to be true
        end

        it 'returns last Friday through Sunday' do
          expected_array = [time - 2.days, time - 1.day, time]
          expect(times_sortable.times_for(times: times)).to match_array expected_array
        end
      end

      context 'when times.max is a Saturday' do
        # Saturday
        let(:time) { Time.parse('2023-06-03') }
        let(:times) { [time - 3.days, time] }

        it 'is Saturday' do
          expect(times.max.saturday?).to be true
        end

        it 'returns last Friday and Saturday' do
          expected_array = [time - 1.day, time]
          expect(times_sortable.times_for(times: times)).to match_array expected_array
        end
      end

      context 'when times.max is a not a Monday or weekend' do
        # Tuesday
        let(:time) { Time.parse('2023-06-06') }
        let(:times) { [time.yesterday.yesterday, time, time.yesterday] }

        it 'is Tuesday' do
          expect(times.max.tuesday?).to be true
        end

        it 'returns times.max - 2.days through times.max' do
          expected_array = [time - 2.days, time - 1.day, time]
          expect(times_sortable.times_for(times: times)).to match_array expected_array
        end
      end
    end
  end
end
