# frozen_string_literal: true

RSpec.describe Dsu::Support::CommandOptions::FromToTimes do
  subject(:from_to_time) do
    Class.new do
      include Dsu::Support::CommandOptions::FromToTimes
    end.new
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
      it 'TODO: test happy path'
    end
  end
end
