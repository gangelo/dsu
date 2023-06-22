# frozen_string_literal: true

RSpec.describe Dsu::Models::Entry do
  subject(:entry) do
    # All defaults are set up to instantiate without errors
    # or vailidation errors by default.
    described_class.new(description: description)
  end

  let(:description) { entry_0_hash[:description] }

  describe '#initialize' do
    it 'initializes #description' do
      expect(entry.description).to eq description
    end

    context 'with invalid arguments' do
      context 'when description is nil' do
        let(:description) { nil }
        let(:expected_error) { /description is the wrong object type/ }

        it_behaves_like 'an error is raised'
      end

      context 'when description is blank' do
        let(:description) { '' }

        it_behaves_like 'no error is raised'
      end

      context 'when desdcription is the wrong type' do
        let(:description) { :invalid }
        let(:expected_error) { /description is the wrong object type/ }

        it_behaves_like 'an error is raised'
      end
    end
  end

  describe 'validations' do
    it 'validates #description with DescriptionValidator' do
      expect(described_class).to validate_with_validator(Dsu::Validators::DescriptionValidator)
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

  describe '#hash' do
    let(:expected_hash) do
      description.hash
    end

    it 'returns the hash of the entry description' do
      expect(entry.hash).to eq(expected_hash)
    end
  end
end
