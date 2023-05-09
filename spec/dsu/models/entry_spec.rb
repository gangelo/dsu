# frozen_string_literal: true

RSpec.describe Dsu::Models::Entry do
  subject(:entry) do
    # All defaults are set up to instantiate without errors
    # or vailidation errors by default.
    described_class.new(
      uuid: uuid,
      description: description
    )
  end

  let(:uuid) { entry_0_hash[:uuid] }
  let(:description) { entry_0_hash[:description] }

  describe '#initialize' do
    it 'initializes the model attributes' do
      expect(subject.uuid).to eq uuid
      expect(subject.description).to eq description
    end

    context 'with invalid arguments' do
      describe ':description' do
        context 'when description is nil' do
          let(:description) { nil }
          let(:expected_error) { /description is nil/ }

          it_behaves_like 'an error is raised'
        end

        context 'when desdcription is the wrong type' do
          let(:description) { :invalid }
          let(:expected_error) { /description is the wrong object type/ }

          it_behaves_like 'an error is raised'
        end
      end

      describe ':uuid' do
        context 'when uuid is the wrong type' do
          let(:uuid) { :invalid }
          let(:expected_error) { /uuid is the wrong object type/ }

          it_behaves_like 'an error is raised'
        end
      end
    end
  end

  describe 'validations' do
    before do
      entry.validate
    end

    describe '#uuid' do
      context 'when uuid is nil' do
        let(:uuid) { nil }

        it_behaves_like 'the validation passes'
      end

      context 'when uuid is not nil and valid' do
        it_behaves_like 'the validation passes'
      end

      context 'when uuid is not nil and invalid' do
        let(:uuid) { 'invalid' }

        let(:expected_errors) do
          [
            'Uuid is the wrong format. 0-9, a-f, and 8 characters were expected.'
          ]
        end

        it_behaves_like 'the validation fails'
      end
    end

    describe '#description' do
      context 'when description is nil' do
        before do
          entry.description = nil
          entry.validate
        end

        let(:expected_errors) do
          [
            "Description can't be blank",
            'Description is too short (minimum is 2 characters)'
          ]
        end

        it_behaves_like 'the validation fails'
      end

      context 'when description is blank?' do
        before do
          entry.description = ''
          entry.validate
        end

        let(:expected_errors) do
          [
            "Description can't be blank",
            'Description is too short (minimum is 2 characters)'
          ]
        end

        it_behaves_like 'the validation fails'
      end

      context 'when description is < 2 chars in length' do
        before do
          entry.description = 'x'
          entry.validate
        end

        let(:expected_errors) do
          [
            'Description is too short (minimum is 2 characters)'
          ]
        end

        it_behaves_like 'the validation fails'
      end

      context 'when description is > 256 chars in length' do
        before do
          entry.description = 'x' * 257
          entry.validate
        end

        let(:expected_errors) do
          [
            'Description is too long (maximum is 256 characters)'
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
