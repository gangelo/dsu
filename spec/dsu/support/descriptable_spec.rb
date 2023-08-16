# frozen_string_literal: true

RSpec.describe Dsu::Support::Descriptable, type: :module do
  subject(:descriptable) do
    Class.new do
      include Dsu::Support::Descriptable

      attr_reader :description

      def initialize(description)
        @description = description
      end
    end.new(description)
  end

  let(:max_desc) { described_class::DESCRIPTION_MAX_COUNT }

  describe '::DESCRIPTION_MAX_COUNT' do
    it 'defines the constant' do
      expect(described_class.const_defined?(:DESCRIPTION_MAX_COUNT)).to be(true)
    end
  end

  describe '#short_description' do
    context 'when description is nil' do
      let(:description) { nil }

      it 'returns an empty string' do
        expect(descriptable.short_description).to eq('')
      end
    end

    context 'when description is an empty string' do
      let(:description) { '' }

      it 'returns an empty string' do
        expect(descriptable.short_description).to eq('')
      end
    end

    context 'when description is a single token' do
      context 'when description length is equal to DESCRIPTION_MAX_COUNT' do
        let(:description) { 'x' * max_desc }

        it 'returns the shortened description' do
          expect(descriptable.short_description).to eq(description)
        end
      end

      context 'when description length is less than DESCRIPTION_MAX_COUNT' do
        let(:description) { 'x' * (max_desc - 5) }

        it 'returns the shortened description' do
          expect(descriptable.short_description).to eq(description)
        end
      end

      context 'when description length is greater than DESCRIPTION_MAX_COUNT' do
        let(:description) { 'x' * (max_desc + 3) }
        let(:expected_short_description) { "#{'x' * (max_desc - 3)}..." }

        it 'returns the shortened description' do
          expect(descriptable.short_description).to eq(expected_short_description)
        end
      end
    end

    context 'when description is multiple tokens' do
      context 'when description length is equal to DESCRIPTION_MAX_COUNT' do
        let(:description) { description_having }

        it 'returns the shortened description' do
          expect(descriptable.short_description).to eq(description)
        end
      end

      context 'when description length is less than DESCRIPTION_MAX_COUNT' do
        let(:description) { description_having(max_length: max_desc - 5) }

        it 'returns the shortened description' do
          expect(descriptable.short_description).to eq(description)
        end
      end

      context 'when description length is greater than DESCRIPTION_MAX_COUNT' do
        let(:description) { 'This is a string of words greater than 25 chars in total' }

        it 'returns the shortened description without breaking up any words' do
          expect(descriptable.short_description).to eq('This is a string of...')
        end
      end
    end
  end
end

def description_having(max_length: Dsu::Support::Descriptable::DESCRIPTION_MAX_COUNT)
  num_words = Dsu::Support::Descriptable::DESCRIPTION_MAX_COUNT
  FFaker::Lorem.words(num_words).join(' ')[0...max_length].tap do |desc|
    desc[-1] = 'x' if desc[-1] == ' '
  end
end
