# frozen_string_literal: true

RSpec.describe Dsu::Services::EntryGroup::CounterService do
  subject(:service) { described_class.new(times: times) }

  let(:time_now) { Time.now.in_time_zone }
  let(:times) { [] }

  describe '#initialize' do
    context 'when argument :times is nil' do
      let(:times) { nil }
      let(:expected_error) { 'Argument times is nil' }

      it_behaves_like 'an error is raised'
    end

    context 'when the arguments are valid' do
      it 'does not raise an error' do
        expect { service }.not_to raise_error
      end
    end
  end

  describe '#call' do
    let(:entry_groups) do
      [
        create(:entry_group, :with_entries, time: time_now - 2.days),
        create(:entry_group, :with_entries, time: time_now - 1.day),
        create(:entry_group, :with_entries, time: time_now)
      ]
    end

    context 'when there are no entry groups for the times given' do
      let(:times) { [entry_groups.map(&:time).min - 1.day] }

      it 'returns 0' do
        expect(service.call).to be 0
      end
    end

    context 'when there are entry groups for the times given' do
      let(:times) { entry_groups.map(&:time) }

      it 'returns the entry group count' do
        expect(service.call).to be times.count
      end
    end
  end
end
