# frozen_string_literal: true

# TODO: Add additional specs for the other methods in this module.
RSpec.describe Dsu::Support::TimeFormatable do
  describe '.mm_dd_yyyy' do
    let(:time) { Time.parse('2/1/2023').localtime }
    let(:separator) { '/' }
    let(:expected_formatted_time) do
      "01#{separator}02#{separator}2023"
    end

    it 'returns the time in mm/dd/yyyy format' do
      expect(described_class.mm_dd_yyyy(time: time, separator: separator)).to eq expected_formatted_time
    end
  end
end
