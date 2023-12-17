# frozen_string_literal: true

# rubocop:disable RSpec/NestedGroups
RSpec.describe Dsu::Support::CommandOptions::DsuTimes do
  subject(:from_to_time) { described_class }

  shared_examples 'the correct times are returned' do
    it 'returns the expected times' do
      times, _errors = from_to_time
      expect(to_yyyymmdd_string_array(times)).to eq(to_yyyymmdd_string_array(expected_times))
    end
  end

  before do
    allow(Time).to receive(:now).and_call_original
  end

  describe '.dsu_times_for' do
    subject(:from_to_time) do
      described_class.dsu_times_for(from_option: from_option, to_option: to_option)
    end

    # No need to test a lot here; this is covered by tests for
    # the modules included in this module.
    context 'when an argument is invalid' do
      context 'when from_option is invalid' do
        let(:from_option) { :not_a_from_command_option }
        let(:to_option) { 'today' }
        let(:expected_error) do
          "Option -f, [--from=DATE|MNEMONIC] value is invalid [\"#{from_option}\"]"
        end

        it 'returns an error' do
          _times, errors = from_to_time
          expect(errors).to include(expected_error)
        end
      end

      context 'when to_option is invalid' do
        let(:from_option) { 'today' }
        let(:to_option) { :not_a_to_command_option }
        let(:expected_error) do
          "Option -t, [--to=DATE|MNEMONIC] value is invalid [\"#{to_option}\"]"
        end

        it 'returns an error' do
          _times, errors = from_to_time
          expect(errors).to include(expected_error)
        end
      end
    end

    context 'when the arguments are valid' do
      context 'when from_option and to_option are both time mnemonics' do
        context "when 'today' and 'tomorrow' respectively" do
          let(:from_option) { 'today' }
          let(:to_option) { 'tomorrow' }
          let(:expected_times) do
            [Time.now, Time.now.tomorrow]
          end

          it_behaves_like 'the correct times are returned'
        end

        context "when 'today' and 'yesterday' respectively" do
          let(:from_option) { 'today' }
          let(:to_option) { 'yesterday' }
          let(:expected_times) do
            [Time.now.yesterday, Time.now]
          end

          it_behaves_like 'the correct times are returned'
        end

        context "when 'tomorrow' and 'today' respectively" do
          let(:from_option) { 'tomorrow' }
          let(:to_option) { 'today' }
          let(:expected_times) do
            [Time.now, Time.now.tomorrow]
          end

          it_behaves_like 'the correct times are returned'
        end

        context "when 'tomorrow' and 'yesterday' respectively" do
          let(:from_option) { 'tomorrow' }
          let(:to_option) { 'yesterday' }
          let(:expected_times) do
            [Time.now.yesterday, Time.now, Time.now.tomorrow]
          end

          it_behaves_like 'the correct times are returned'
        end
      end

      context 'when from_option and to_option are relative time mnemonics' do
        context "when '-2' and '-2' respectively" do
          let(:from_option) { '-1' }
          let(:to_option) { '-2' }
          let(:expected_times) do
            from_date = from_option.to_i.days.from_now.to_date
            to_date = to_option.to_i.days.from_now(from_date).to_date
            dates = [from_date, to_date].sort
            (dates.min..dates.max).map(&:to_time)
          end

          it_behaves_like 'the correct times are returned'
        end
      end

      context 'when from_option is a time mnemonic and to_option is a relative time mnemonic' do
        context "when 'today' and 'tomorrow' respectively" do
          let(:from_option) { 'today' }
          let(:to_option) { '+2' }
          let(:expected_times) do
            [Time.now, Time.now.tomorrow, Time.now.tomorrow.tomorrow]
          end

          it_behaves_like 'the correct times are returned'
        end
      end

      context 'when from_option is a relative time mnemonic and to_option is a time mnemonic' do
        context "when 'today' and 'tomorrow' respectively" do
          let(:from_option) { '+2' }
          let(:to_option) { 'yesterday' }
          let(:expected_times) do
            from_date = from_option.to_i.days.from_now.to_date
            to_date = Time.now.yesterday.to_date
            dates = [from_date, to_date].sort
            (dates.min..dates.max).map(&:to_time)
          end

          it_behaves_like 'the correct times are returned'
        end
      end
    end
  end
end
# rubocop:enable RSpec/NestedGroups
