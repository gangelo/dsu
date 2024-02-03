# frozen_string_literal: true

RSpec.describe Dsu::Support::ShortString, type: :module do
  subject(:short_string) { described_class.short_string(string: description) }

  let(:max_desc) { described_class::SHORT_STRING_MAX_COUNT }

  describe '::SHORT_STRING_MAX_COUNT' do
    it 'defines the constant' do
      expect(described_class.const_defined?(:SHORT_STRING_MAX_COUNT)).to be(true)
    end
  end

  describe '.short_string' do
    context 'when description is nil' do
      let(:description) { nil }

      it 'returns an empty string' do
        expect(short_string).to eq('')
      end
    end

    context 'when description is an empty string' do
      let(:description) { '' }

      it 'returns an empty string' do
        expect(short_string).to eq('')
      end
    end

    context 'when description is a single token' do
      context 'when description length is equal to SHORT_STRING_MAX_COUNT' do
        let(:description) { 'x' * max_desc }

        it 'returns the shortened description' do
          expect(short_string).to eq(description)
        end
      end

      context 'when description length is less than SHORT_STRING_MAX_COUNT' do
        let(:description) { 'x' * (max_desc - 5) }

        it 'returns the shortened description' do
          expect(short_string).to eq(description)
        end
      end

      context 'when description length is greater than SHORT_STRING_MAX_COUNT' do
        let(:description) { 'x' * (max_desc + 3) }
        let(:expected_short_description) { "#{'x' * (max_desc - 3)}..." }

        it 'returns the shortened description' do
          expect(short_string).to eq(expected_short_description)
        end
      end
    end

    context 'when description is multiple tokens' do
      context 'when description length is equal to SHORT_STRING_MAX_COUNT' do
        let(:description) { description_having }

        it 'returns the shortened description' do
          expect(short_string).to eq(description)
        end
      end

      context 'when description length is less than SHORT_STRING_MAX_COUNT' do
        let(:description) { description_having(max_length: max_desc - 5) }

        it 'returns the shortened description' do
          expect(short_string).to eq(description)
        end
      end

      context 'when description length is greater than SHORT_STRING_MAX_COUNT' do
        let(:description) { 'This is a string of words greater than 25 chars in total' }

        it 'returns the shortened description without breaking up any words' do
          expect(short_string).to eq('This is a string of...')
        end
      end
    end
  end
end
