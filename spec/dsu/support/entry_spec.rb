# frozen_string_literal: true

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Dsu::Support::Entry do
  subject(:entry) do
    # All defaults are set up to instantiate without errors
    # or vailidation errors by default.
    described_class.new(
      uuid: uuid,
      description: description,
      order: order,
      time: time,
      long_description: long_description,
      version: version
    )
  end

  before do
    stub_entries_version
  end

  let(:uuid) { entry_0_hash[:uuid] }
  let(:description) { entry_0_hash[:description] }
  let(:order) { entry_0_hash[:order] }
  let(:time) { entry_0_hash[:time] }
  let(:long_description) { entry_0_hash[:long_description] }
  let(:version) { entry_0_hash[:version] }

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
        let(:description) { nil }
        let(:expected_errors) do
          [
            "Description can't be blank",
            'Description is too short (minimum is 2 characters)'
          ]
        end

        it_behaves_like 'the validation fails'
      end

      context 'when description is blank?' do
        let(:description) { '' }
        let(:expected_errors) do
          [
            "Description can't be blank",
            'Description is too short (minimum is 2 characters)'
          ]
        end

        it_behaves_like 'the validation fails'
      end

      context 'when description is < 2 chars in length' do
        let(:description) { 'x' }
        let(:expected_errors) do
          [
            'Description is too short (minimum is 2 characters)'
          ]
        end

        it_behaves_like 'the validation fails'
      end

      context 'when description is > 80 chars in length' do
        let(:description) { 'x' * 81 }
        let(:expected_errors) do
          [
            'Description is too long (maximum is 80 characters)'
          ]
        end

        it_behaves_like 'the validation fails'
      end
    end

    describe '#long_description' do
      context 'when long_description is nil' do
        let(:long_description) { nil }

        it_behaves_like 'the validation passes'
      end

      context 'when long_description is blank?' do
        let(:long_description) { '' }
        let(:expected_errors) do
          [
            'Long description is too short (minimum is 2 characters)'
          ]
        end

        it_behaves_like 'the validation fails'
      end

      context 'when long_description is < 2 chars in length' do
        let(:long_description) { 'x' }
        let(:expected_errors) do
          [
            'Long description is too short (minimum is 2 characters)'
          ]
        end

        it_behaves_like 'the validation fails'
      end

      context 'when long_description is > 256 chars in length' do
        let(:long_description) { 'x' * 257 }
        let(:expected_errors) do
          [
            'Long description is too long (maximum is 256 characters)'
          ]
        end

        it_behaves_like 'the validation fails'
      end
    end

    describe '#order' do
      context 'when order is nil' do
        let(:order) { nil }
        let(:expected_errors) do
          [
            'Order is not a number'
          ]
        end

        it_behaves_like 'the validation fails'
      end

      context 'when order is blank?' do
        let(:order) { '' }
        let(:expected_errors) do
          [
            'Order is not a number'
          ]
        end

        it_behaves_like 'the validation fails'
      end

      context 'when order is >= 0' do
        let(:order) { 0 }

        it_behaves_like 'the validation passes'
      end

      context 'when order is < 0' do
        let(:order) { -1 }
        let(:expected_errors) do
          [
            'Order must be greater than or equal to 0'
          ]
        end

        it_behaves_like 'the validation fails'
      end

      context 'when order is not an integer' do
        let(:order) { 1.0 }
        let(:expected_errors) do
          [
            'Order must be an integer'
          ]
        end

        it_behaves_like 'the validation fails'
      end
    end

    describe '#time' do
      context 'when time is nil' do
        let(:time) { nil }

        it_behaves_like 'the validation passes'

        it 'uses Time.now.utc' do
          expect(entry.time).to eq time_utc
        end
      end
    end

    describe '#version' do
      context 'when version is nil' do
        let(:version) { nil }

        it_behaves_like 'the validation passes'

        it 'uses the current entries version' do
          expect(entry.version).to eq entries_version
        end
      end

      context 'when version is blank?' do
        let(:version) { '' }
        let(:expected_errors) do
          [
            "Version can't be blank",
            'Version is the wrong format. /\\d+\\.\\d+\\.\\d+/ format was expected, but the version format did not match.'
          ]
        end

        it_behaves_like 'the validation fails'
      end

      context 'when version is the wrong format' do
        let(:version) { 'v0..1.0' }
        let(:expected_errors) do
          [
            'Version is the wrong format. /\\d+\\.\\d+\\.\\d+/ format was expected, but the version format did not match.'
          ]
        end

        it_behaves_like 'the validation fails'
      end
    end
  end

  describe '#initialize' do
    context 'when :time is not a Time object' do
      let(:time) { :bad }
      let(:expected_error) { /time is the wrong object type/ }

      it_behaves_like 'an error is raised'
    end
  end

  describe '#to_h' do
    it 'returns a Hash representing the Entry' do
      expect(entry.to_h).to eq(entry_0_hash)
    end
  end

  describe '#to_h_localized' do
    it 'returns a Hash representing the Entry with dates/times localized' do
      expect(entry.to_h_localized).to \
        eq entry_0_hash.merge({ time: entry_0_hash[:time].localtime })
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
# rubocop:enable RSpec/MultipleMemoizedHelpers
