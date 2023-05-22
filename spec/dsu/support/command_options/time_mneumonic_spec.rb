# frozen_string_literal: true

RSpec.describe Dsu::Support::CommandOptions::TimeMneumonic do
  subject(:time_mneumonic) do
    Class.new do
      include Dsu::Support::CommandOptions::TimeMneumonic
    end.new.time_from_mneumonic!(command_option: command_option, relative_time: relative_time)
  end

  describe '#time_from_mneumonic!' do
    context 'when the command_option argument is invalid' do
      context 'when a valid date string' do
        let(:command_option) { '5/1/2023' }
        let(:relative_time) { nil }
        let(:expected_error) { /command_option is an invalid mneumonic/ }

        it_behaves_like 'an error is raised'
      end

      context 'when nil' do
        let(:command_option) { nil }
        let(:relative_time) { nil }
        let(:expected_error) { /command_option cannot be nil/ }

        it_behaves_like 'an error is raised'
      end

      context 'when blank' do
        let(:command_option) { '' }
        let(:relative_time) { nil }
        let(:expected_error) { /command_option cannot be blank/ }

        it_behaves_like 'an error is raised'
      end

      context 'when not a String' do
        let(:command_option) { :not_a_string }
        let(:relative_time) { nil }
        let(:expected_error) { /command_option must be a String/ }

        it_behaves_like 'an error is raised'
      end

      context 'when an invalid mneumonic' do
        let(:command_option) { 'not a mneumonic' }
        let(:relative_time) { nil }
        let(:expected_error) { /command_option is an invalid mneumonic/ }

        it_behaves_like 'an error is raised'
      end
    end

    context 'when the relative_time argument is invalid' do
      context 'when a valid date string' do
        let(:command_option) { 'today' }
        let(:relative_time) { '5/1/2023' }
        let(:expected_error) { /relative_time is an invalid mneumonic/ }

        it_behaves_like 'an error is raised'
      end

      context 'when nil' do
        let(:command_option) { 'today' }
        let(:relative_time) { nil }
        let(:expected_error) { /relative_time cannot be nil/ }

        it_behaves_like 'an error is raised'
      end

      context 'when blank' do
        let(:command_option) { 'yesterday' }
        let(:relative_time) { '' }
        let(:expected_error) { /relative_time cannot be blank/ }

        it_behaves_like 'an error is raised'
      end

      context 'when not a String' do
        let(:command_option) { 'tomorrow' }
        let(:relative_time) { :not_a_string }
        let(:expected_error) { /relative_time must be a String/ }

        it_behaves_like 'an error is raised'
      end

      context 'when an invalid mneumonic' do
        let(:command_option) { 'n' }
        let(:relative_time) { 'not a mneumonic' }
        let(:expected_error) { /relative_time is an invalid mneumonic/ }

        it_behaves_like 'an error is raised'
      end
    end
  end
end
