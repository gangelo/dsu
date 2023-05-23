# frozen_string_literal: true

RSpec.shared_examples 'the correct time is returned' do
  it 'returns the expected time' do
    expect(to_yyyymmdd_string(time_from_mneumonic)).to eq(to_yyyymmdd_string(expected_time))
  end
end

# rubocop:disable RSpec/NestedGroups
RSpec.describe Dsu::Support::CommandOptions::TimeMneumonic do
  subject(:time_from_mneumonic) do
    Class.new do
      include Dsu::Support::CommandOptions::TimeMneumonic
    end.new.time_from_mneumonic!(command_option: command_option, relative_time: relative_time)
  end

  before do
    allow(Time).to receive(:now).and_call_original
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

    context 'when the relative_time argument is not a Time object' do
      let(:command_option) { 'yesterday' }
      let(:relative_time) { :not_a_time }
      let(:expected_error) { /relative_time is not a Time object/ }

      it_behaves_like 'an error is raised'
    end

    # The following tests are for the case where the arguments are valid.
    context 'when command_option is valid' do
      context "when 'today'" do
        let(:command_option) { 'today' }
        let(:relative_time) { nil }
        let(:expected_time) { Time.now }

        it_behaves_like 'the correct time is returned'
      end

      context "when 'yesterday'" do
        let(:command_option) { 'yesterday' }
        let(:relative_time) { nil }
        let(:expected_time) { Time.now.yesterday }

        it_behaves_like 'the correct time is returned'
      end

      context "when 'tomorrow'" do
        let(:command_option) { 'tomorrow' }
        let(:relative_time) { nil }
        let(:expected_time) { Time.now.tomorrow }

        it_behaves_like 'the correct time is returned'
      end

      context 'when a positive (+), relative time mneumonic' do
        let(:command_option) { '+1' }
        let(:relative_time) { nil }
        let(:expected_time) { Time.now.tomorrow }

        it_behaves_like 'the correct time is returned'
      end

      context 'when a negative (-), relative time mneumonic' do
        let(:command_option) { '-1' }
        let(:relative_time) { nil }
        let(:expected_time) { Time.now.yesterday }

        it_behaves_like 'the correct time is returned'
      end
    end

    context 'when command_option and relative_time are both valid' do
      context "when 'today' and 'Time.now.tomorrow' respectfully" do
        let(:command_option) { 'today' }
        let(:relative_time) { Time.now.tomorrow }
        let(:expected_time) { Time.now.tomorrow }

        it_behaves_like 'the correct time is returned'
      end

      context "when 'today' and 'Time.now.yesterday' respectfully" do
        let(:command_option) { 'today' }
        let(:relative_time) { Time.now.yesterday }
        let(:expected_time) { Time.now.yesterday }

        it_behaves_like 'the correct time is returned'
      end

      context "when a (positive, +n) relative time mneumonic and 'Time.now' respectfully" do
        let(:command_option) { '+7' }
        let(:relative_time) { Time.now }
        let(:expected_time) { 7.days.from_now }

        it_behaves_like 'the correct time is returned'
      end

      context "when a (negative, -n) relative time mneumonic and 'Time.now' respectfully" do
        let(:command_option) { '-7' }
        let(:relative_time) { Time.now }
        let(:expected_time) { -7.days.from_now }

        it_behaves_like 'the correct time is returned'
      end

      context 'when command_option is a time mneumonic' do
        context "when 'today' and 'Time.now.tomorrow' respectfully" do
          let(:command_option) { 'today' }
          let(:relative_time) { Time.now.tomorrow }
          let(:expected_time) { Time.now.tomorrow }

          it_behaves_like 'the correct time is returned'
        end

        context "when 'today' and 'Time.now.yesterday' respectfully" do
          let(:command_option) { 'today' }
          let(:relative_time) { Time.now.yesterday }
          let(:expected_time) { Time.now.yesterday }

          it_behaves_like 'the correct time is returned'
        end

        context "when 'tomorrow' and 'Time.now' respectfully" do
          let(:command_option) { 'tomorrow' }
          let(:relative_time) { Time.now }
          let(:expected_time) { Time.now.tomorrow }

          it_behaves_like 'the correct time is returned'
        end

        context "when 'tomorrow' and 'Time.now.yesterday' respectfully" do
          let(:command_option) { 'tomorrow' }
          let(:relative_time) { Time.now.yesterday }
          let(:expected_time) { Time.now }

          it_behaves_like 'the correct time is returned'
        end

        context "when 'yesterday' and 'Time.now' respectfully" do
          let(:command_option) { 'yesterday' }
          let(:relative_time) { Time.now }
          let(:expected_time) { Time.now.yesterday }

          it_behaves_like 'the correct time is returned'
        end

        context "when 'yesterday' and 'Time.now.tomorrow' respectfully" do
          let(:command_option) { 'yesterday' }
          let(:relative_time) { Time.now.tomorrow }
          let(:expected_time) { Time.now }

          it_behaves_like 'the correct time is returned'
        end
      end

      context 'when command_option and relative_time are both time relative mneumonics' do
        context "when '+1' and 'Time.now.tomorrow' respectfully" do
          let(:command_option) { '+1' }
          let(:relative_time) { Time.now.tomorrow }
          let(:expected_time) { Time.now.tomorrow.tomorrow }

          it_behaves_like 'the correct time is returned'
        end

        context "when '-1' and 'Time.now.yesterday' respectfully" do
          let(:command_option) { '-1' }
          let(:relative_time) { Time.now.yesterday }
          let(:expected_time) { Time.now.yesterday.yesterday }

          it_behaves_like 'the correct time is returned'
        end

        context "when '-1' and 'Time.now.tomorrow' respectfully" do
          let(:command_option) { '-1' }
          let(:relative_time) { Time.now.tomorrow }
          let(:expected_time) { Time.now }

          it_behaves_like 'the correct time is returned'
        end

        context "when '-2' and '4.days.from_now' respectfully" do
          let(:command_option) { '-2' }
          let(:relative_time) { 4.days.from_now }
          let(:expected_time) { Time.now.tomorrow.tomorrow }

          it_behaves_like 'the correct time is returned'
        end
      end
    end
  end
end
# rubocop:enable RSpec/NestedGroups
