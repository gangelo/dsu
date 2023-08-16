# frozen_string_literal: true

require 'active_support/core_ext/date/calculations'

RSpec.describe WrapAndJoin do
  describe 'constants' do
    describe 'WRAP_AND_JOIN_JOIN_TOKEN' do
      it 'defines the constant' do
        expect(Array.const_defined?(:WRAP_AND_JOIN_JOIN_TOKEN)).to be true
      end

      it 'assignes the constant value' do
        expect(Array::WRAP_AND_JOIN_JOIN_TOKEN).to eq ', '
      end
    end
  end

  describe '#wrap_and_join' do
    context 'when no arguments are passed' do
      it 'returns a string with each element quoted, joined by a comma' do
        expect(%w[one two three].wrap_and_join).to eq '"one", "two", "three"'
      end
    end

    context 'when join is passed' do
      it 'returns a string with each element quoted and joined by the join token' do
        expect(%w[one two three].wrap_and_join(join: ' | ')).to eq '"one" | "two" | "three"'
      end
    end

    context 'when a wrapper with 1 token is passed' do
      it 'returns a string with each element wrapped in the wrap token and joined by a comma' do
        expect(%w[one two three].wrap_and_join(wrapper: %w[*], join: ' + ')).to eq '*one* + *two* + *three*'
      end
    end

    context 'when a wrapper with 2 tokens is passed' do
      it 'returns a string with each element wrapped in the wrap token and joined by a comma' do
        expect(%w[one two three].wrap_and_join(wrapper: %w[[ ]], join: ' | ')).to eq '[one] | [two] | [three]'
      end
    end
  end
end
