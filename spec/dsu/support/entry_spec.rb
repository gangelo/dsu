# frozen_string_literal: true

RSpec.shared_examples 'an error is raised' do
  it 'raises an error' do
    expect { entry }.to raise_error expected_error
  end
end

RSpec.shared_examples 'no error is raised' do
  it 'does not raise an error' do
    expect { entry }.not_to raise_error
  end
end

RSpec.shared_examples 'the validation fails' do
  it 'fails validation' do
    expect(entry.errors.full_messages).to eq expected_errors
  end
end

RSpec.shared_examples 'the validation passes' do
  it 'passes validation' do
    expect(entry.valid?).to be true
  end
end

RSpec.describe Dsu::Support::Entry do
  subject(:entry) do
    described_class.new(
      description: description,
      order: order,
      time: time,
      long_description: long_description,
      version: version
    )
  end

  let(:arguments) do
    {
      description: description,
      order: order,
      time: time,
      long_description: long_description,
      version: version
    }
  end
  let(:description) { 'description' }
  let(:order) { 0 }
  let(:time) { time_utc }
  let(:long_description) { nil }
  let(:version) { Dsu::Support::EntriesVersion::ENTRIES_VERSION }

  describe 'validations' do
    before do
      entry.validate
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
    end

    describe '#version' do
    end
  end

  describe '#initialize' do
    describe 'arguments' do
      context 'when time is nil' do
        let(:time) { nil }

        it_behaves_like 'no error is raised'

        it 'uses Time.now.utc' do
          expect(entry.time).to eq time_utc
        end
      end

      context 'when time is not a Time object' do
        let(:time) { :bad }
        let(:expected_error) { /:time is not a Time object/ }

        it_behaves_like 'an error is raised'
      end

      describe ':order' do
        context 'when order is nil' do
          it 'does something awesome' do
            binding.pry
          end
        end
      end
    end
  end
end
