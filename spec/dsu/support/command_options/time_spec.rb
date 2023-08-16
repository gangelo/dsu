# frozen_string_literal: true

RSpec.describe Dsu::Support::CommandOptions::Time do
  before do
    allow(Time).to receive(:now).and_call_original
  end

  describe '.time_from_date_string' do
    subject(:time) do
      described_class.time_from_date_string(command_option: command_option)
    end

    context 'when the argument is invalid' do
      context 'when command_option is nil' do
        let(:command_option) { nil }

        it 'returns nil' do
          expect(time).to be_nil
        end
      end

      context 'when command_option is blank' do
        let(:command_option) { '' }

        it 'returns nil' do
          expect(time).to be_nil
        end
      end

      context 'when command_option is not a String' do
        let(:command_option) { :not_a_string }

        it 'returns nil' do
          expect(time).to be_nil
        end
      end
    end
  end

  describe '.time_from_date_string!' do
    subject(:time) do
      described_class.time_from_date_string!(command_option: command_option)
    end

    context 'when the argument is invalid' do
      context 'when command_option is nil' do
        let(:command_option) { nil }
        let(:expected_error) { /command_option is nil/ }

        it_behaves_like 'an error is raised'
      end

      context 'when command_option is blank' do
        let(:command_option) { '' }
        let(:expected_error) { /command_option is blank/ }

        it_behaves_like 'an error is raised'
      end

      context 'when command_option is not a String' do
        let(:command_option) { :not_a_string }
        let(:expected_error) { /command_option is not a String/ }

        it_behaves_like 'an error is raised'
      end

      context 'when the command_option is not a formattable date' do
        let(:command_option) { '2/31' }
        let(:expected_error) { %r{command_option is not a valid date: "2/31"} }

        it_behaves_like 'an error is raised'
      end
    end

    context 'when the argument is valid' do
      context 'when the command_option is a formattable date MM/DD/YYYY' do
        let(:command_option) { '02/01/2023' }

        it 'returns a Time object' do
          expect(to_yyyymmdd_string(time)).to eq('2023-02-01')
        end
      end

      context 'when the command_option is a formattable date M/D/YYYY' do
        let(:command_option) { '2/1/2023' }

        it 'returns a Time object' do
          expect(to_yyyymmdd_string(time)).to eq('2023-02-01')
        end
      end

      context 'when the command_option is a formattable date M/D' do
        let(:command_option) { '2/1' }

        it 'returns a Time object' do
          expect(to_yyyymmdd_string(time)).to eq('2023-02-01')
        end
      end
    end
  end
end
