# frozen_string_literal: true

RSpec.describe Dsu::Models::Entry do
  subject(:entry) do
    # All defaults are set up to instantiate without errors
    # or vailidation errors by default.
    described_class.new(description: description)
  end

  let(:description) { entry_0_hash[:description] }

  describe '#initialize' do
    it 'initializes the model attributes' do
      expect(subject.description).to eq description
    end

    context 'with invalid arguments' do
      context 'when description is nil' do
        let(:description) { nil }
        let(:expected_error) { /description is nil/ }

        it_behaves_like 'an error is raised'
      end

      context 'when description is blank' do
        let(:description) { '' }
        let(:expected_error) { /description is blank/ }

        it_behaves_like 'an error is raised'
      end

      context 'when desdcription is the wrong type' do
        let(:description) { :invalid }
        let(:expected_error) { /description is the wrong object type/ }

        it_behaves_like 'an error is raised'
      end
    end
  end

  describe 'validations' do
    before do
      entry.validate
    end

    describe '#description' do
      context 'when < 2 chars in length' do
        before do
          entry.validate
        end

        let(:description) { 'x' }
        let(:expected_errors) do
          [
            /Description is too short/
          ]
        end

        it_behaves_like 'the validation fails'
      end

      context 'when > 256 chars in length' do
        before do
          entry.validate
        end

        let(:description) { 'x' * 257 }
        let(:expected_errors) do
          [
            /Description is too long/
          ]
        end

        it_behaves_like 'the validation fails'
      end
    end
  end

  describe '#to_h' do
    it 'returns a Hash representing the Entry' do
      expect(entry.to_h).to eq(entry_0_hash)
    end
  end

  describe '#==' do
    context 'when the entries are equal' do
      let(:equal_entry) { described_class.new(**entry_0_hash) }

      it 'returns true' do
        expect(entry == equal_entry).to be true
      end
    end

    context 'when the entry is not equal' do
      context 'when the entry is nil' do
        it 'returns false' do
          expect(entry.nil?).to be false
        end
      end

      context 'when the entry is not an Entry' do
        it 'returns false' do
          expect(entry == 'not an entry').to be false
        end
      end

      context 'when the entries are not equal' do
        let(:not_equal_entry) { described_class.new(description: 'not equal entry') }

        it 'returns false' do
          expect(entry == not_equal_entry).to be false
        end
      end
    end
  end
end
