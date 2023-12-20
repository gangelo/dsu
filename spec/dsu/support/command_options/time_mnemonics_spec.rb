# frozen_string_literal: true

RSpec.describe Dsu::Support::CommandOptions::TimeMnemonics do
  describe 'constants' do
    it 'defines TODAY' do
      expect(described_class::TODAY).to match_array(%w[n today])
    end

    it 'defines TOMORROW' do
      expect(described_class::TOMORROW).to match_array(%w[t tomorrow])
    end

    it 'defines YESTERDAY' do
      expect(described_class::YESTERDAY).to match_array(%w[y yesterday])
    end

    it 'defines RELATIVE_REGEX' do
      expect(described_class::RELATIVE_REGEX).to eq(/\A[+-]\d+\z/)
    end
  end
end
