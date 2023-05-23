# frozen_string_literal: true

# rubocop:disable RSpec/NestedGroups
RSpec.shared_examples 'the correct times are returned' do
  it 'returns the expected times' do
    expect(to_yyyymmdd_string_array(from_to_time)).to eq(to_yyyymmdd_string_array(expected_times))
  end
end

RSpec.describe Dsu::Support::CommandOptions::FromToTimes do
  subject(:from_to_time) do
    Class.new do
      include Dsu::Support::CommandOptions::FromToTimes
    end.new
  end

  before do
    allow(Time).to receive(:now).and_call_original
  end

  describe '.from_to_times_for!' do
    subject(:from_to_time) do
      Class.new do
        include Dsu::Support::CommandOptions::FromToTimes
      end.new.from_to_times_for!(from_command_option: from_command_option, to_command_option: to_command_option)
    end

    # No need to test a lot here; this is covered by tests for
    # the modules included in this module.
    context 'when an argument is invalid' do
      context 'when from_command_option is invalid' do
        let(:from_command_option) { :not_a_from_command_option }
        let(:to_command_option) { 'today' }
        let(:expected_error) { ArgumentError }

        it_behaves_like 'an error is raised'
      end

      context 'when to_command_option is invalid' do
        let(:from_command_option) { 'today' }
        let(:to_command_option) { :not_a_to_command_option }
        let(:expected_error) { ArgumentError }

        it_behaves_like 'an error is raised'
      end
    end

    context 'when the arguments are valid' do
      context 'when from_command_option and to_command_option are both time mneumonics' do
        context "when 'today' and 'tomorrow' respectively" do
          let(:from_command_option) { 'today' }
          let(:to_command_option) { 'tomorrow' }
          let(:expected_times) do
            [Time.now, Time.now.tomorrow]
          end

          it_behaves_like 'the correct times are returned'
        end

        context "when 'today' and 'yesterday' respectively" do
          let(:from_command_option) { 'today' }
          let(:to_command_option) { 'yesterday' }
          let(:expected_times) do
            [Time.now.yesterday, Time.now]
          end

          it_behaves_like 'the correct times are returned'
        end

        context "when 'tomorrow' and 'today' respectively" do
          let(:from_command_option) { 'tomorrow' }
          let(:to_command_option) { 'today' }
          let(:expected_times) do
            [Time.now, Time.now.tomorrow]
          end

          it_behaves_like 'the correct times are returned'
        end

        context "when 'tomorrow' and 'yesterday' respectively" do
          let(:from_command_option) { 'tomorrow' }
          let(:to_command_option) { 'yesterday' }
          let(:expected_times) do
            [Time.now.yesterday, Time.now, Time.now.tomorrow]
          end

          it_behaves_like 'the correct times are returned'
        end
      end

      context 'when from_command_option is a time mneumonic and to_command_option is a relative time mneumonic' do
        context "when 'today' and 'tomorrow' respectively" do
          let(:from_command_option) { 'today' }
          let(:to_command_option) { '+2' }
          let(:expected_times) do
            [Time.now, Time.now.tomorrow, Time.now.tomorrow.tomorrow]
          end

          it_behaves_like 'the correct times are returned'
        end
      end
    end
  end
end
# rubocop:enable RSpec/NestedGroups
