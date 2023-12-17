# frozen_string_literal: true

RSpec.describe Dsu::Support::CommandOptions::TimeMnemonics do
  describe 'constants' do
    it 'defines TODAY' do
      expect(described_class::TODAY).to match_array(%w[n today])
    end

    it 'defines TOMORROW' do
      expect(described_class::TOMORROW).to match_array(%w[t tomorrow])
    end

    it 'defines YESERDAY' do
      expect(described_class::YESERDAY).to match_array(%w[y yesterday])
    end

    it 'defines RELATIVE_REGEX' do
      expect(described_class::RELATIVE_REGEX).to eq(/[+-]\d+/)
    end
  end
end
