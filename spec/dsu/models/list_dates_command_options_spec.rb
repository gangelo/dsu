# frozen_string_literal: true

RSpec.describe Dsu::Models::ListDatesCommandOptions do
  subject(:list_dates_command_options) do
    described_class.new(options: options)
  end

  let(:options) { {} }

  describe '#initialize' do
    context 'with invalid arguments' do
      context 'when options is nil' do
        let(:options) { nil }
        let(:expected_error) { /options is the wrong object type/ }

        it_behaves_like 'an error is raised'
      end

      context 'when options is the wrong type' do
        let(:options) { :invalid }
        let(:expected_error) { /options is the wrong object type/ }

        it_behaves_like 'an error is raised'
      end

      context 'when the :from option is nil' do
        let(:options) { { to: '02/01/2023' } }
        let(:expected_error) { /From can't be blank/ }

        it_behaves_like 'an error is raised'
      end

      context 'when the :to option is nil' do
        let(:options) { { from: '02/01/2023' } }
        let(:expected_error) { /To can't be blank/ }

        it_behaves_like 'an error is raised'
      end

      context 'when the :from option is not a formattable date' do
        let(:options) do
          {
            from: '2/31',
            to: '02/01/2023'
          }
        end
        let(:expected_error) do
          /From \("2022\/2\/31"\) is not formattable/ # rubocop:disable Style/RegexpLiteral
        end

        it_behaves_like 'an error is raised'
      end

      context 'when the :to option is not a formattable date' do
        let(:options) do
          {
            from: '02/01/2023',
            to: '2/31'
          }
        end
        let(:expected_error) do
          /To \("2022\/2\/31"\) is not formattable/ # rubocop:disable Style/RegexpLiteral
        end

        it_behaves_like 'an error is raised'
      end

      context 'when the date range between :from and :to is too great' do
        let(:options) do
          {
            from: '01/01/2023',
            to: '01/02/2024'
          }
        end
        let(:expected_error) do
          /Date range is greater that/
        end

        it_behaves_like 'an error is raised'
      end
    end

    context 'with valid arguments' do
      let(:options) do
        {
          from: '05/01/2023',
          to: '05/07/2023'
        }
      end

      describe '#from' do
        it 'returns the correct date' do
          expected_time = Time.strptime(options[:from], '%m/%d/%Y')
          expect(list_dates_command_options.from).to eq(expected_time)
        end
      end

      describe '#to' do
        it 'returns the correct date' do
          expected_time = Time.strptime(options[:to], '%m/%d/%Y')
          expect(list_dates_command_options.to).to eq(expected_time)
        end
      end
    end
  end

  describe 'validations' do
    context 'when the options are valid' do
      context 'when the :from and :to options are valid dates' do
        let(:options) do
          {
            from: '02/01/2023',
            to: '02/02/2023'
          }
        end

        it_behaves_like 'the validation passes'
      end

      context 'when the :to option is the same as the :from option' do
        let(:options) do
          {
            from: '02/01/2023',
            to: '02/01/2023'
          }
        end

        it_behaves_like 'the validation passes'
      end
    end

    context 'when the :to option is before the :from option' do
      it 'does something'
    end
  end
end
