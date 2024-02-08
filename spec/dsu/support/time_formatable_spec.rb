# frozen_string_literal: true

# TODO: Add additional specs for the other methods in this module.
RSpec.describe Dsu::Support::TimeFormatable do
  describe '.formatted_time' do
    shared_examples 'the time is formatted correctly' do
      it 'returns the formatted time' do
        expect(described_class.formatted_time(time: time)).to eq expected_formatted_time
      end
    end

    context 'when today' do
      let(:time) { Time.now.in_time_zone }
      let(:expected_formatted_time) do
        time.strftime("%A, (Today) %Y-%m-%d #{time.zone}")
      end

      it_behaves_like 'the time is formatted correctly'
    end

    context 'when yesterday' do
      let(:time) { Time.now.yesterday.in_time_zone }
      let(:expected_formatted_time) do
        time.strftime("%A, (Yesterday) %Y-%m-%d #{time.zone}")
      end

      it_behaves_like 'the time is formatted correctly'
    end

    context 'when tomorrow' do
      let(:time) { Time.now.tomorrow.in_time_zone }
      let(:expected_formatted_time) do
        time.strftime("%A, (Tomorrow) %Y-%m-%d #{time.zone}")
      end

      it_behaves_like 'the time is formatted correctly'
    end
  end

  describe '.mm_dd' do
    let(:time) { Time.parse('2/1/2023').in_time_zone }
    let(:separator) { '/' }
    let(:expected_formatted_time) do
      "01#{separator}02"
    end

    it 'returns the time in mm/dd format' do
      expect(described_class.mm_dd(time: time, separator: separator)).to eq expected_formatted_time
    end
  end

  describe '.mm_dd_yyyy' do
    let(:time) { Time.parse('2/1/2023').in_time_zone }
    let(:separator) { '/' }
    let(:expected_formatted_time) do
      "01#{separator}02#{separator}2023"
    end

    it 'returns the time in mm/dd/yyyy format' do
      expect(described_class.mm_dd_yyyy(time: time, separator: separator)).to eq expected_formatted_time
    end
  end

  describe '.dd_mm_yyyy' do
    let(:time) { Time.parse('2/1/2023').in_time_zone }
    let(:separator) { '/' }
    let(:expected_formatted_time) do
      "02#{separator}01#{separator}2023"
    end

    it 'returns the time in dd/mm/yyyy format' do
      expect(described_class.dd_mm_yyyy(time: time, separator: separator)).to eq expected_formatted_time
    end
  end

  describe '.yyyy_mm_dd' do
    let(:time) { Time.parse('2/1/2023').in_time_zone }
    let(:separator) { '/' }
    let(:expected_formatted_time) do
      "2023#{separator}01#{separator}02"
    end

    it 'returns the time in yyyy/mm/dd format' do
      expect(described_class.yyyy_mm_dd(time: time, separator: separator)).to eq expected_formatted_time
    end
  end

  describe '.yyyy_mm_dd_or_through_for' do
    shared_examples 'the time is formatted correctly' do
      it 'returns the formatted time' do
        expect(described_class.yyyy_mm_dd_or_through_for(times: times)).to eq expected_formatted_time
      end
    end

    context 'when only one time is passed' do
      let(:times) { [Time.parse('2/1/2023').in_time_zone] }
      let(:separator) { '-' }
      let(:expected_formatted_time) do
        "2023#{separator}01#{separator}02"
      end

      it_behaves_like 'the time is formatted correctly'
    end

    context 'when multiple times are passed' do
      let(:time) { Time.now.in_time_zone }
      let(:times) { [time.yesterday, time, time.tomorrow] }
      let(:separator) { '-' }
      let(:expected_formatted_time) do
        min, max = times.minmax.map { |t| described_class.yyyy_mm_dd(time: t, separator: separator) }
        "#{min} thru #{max}"
      end

      it_behaves_like 'the time is formatted correctly'
    end
  end
end
