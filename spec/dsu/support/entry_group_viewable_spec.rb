# frozen_string_literal: true

def entry_groups_regex_for(times:, options: {})
  regex_string = times.map do |time|
    if Dsu::Models::EntryGroup.exist?(time: time)
      entry_group = Dsu::Models::EntryGroup.find(time: time)
      ".*#{Dsu::Support::TimeFormatable.formatted_time(time: time)}.*#{entry_group.entries[0].description}.*#{entry_group.entries[1].description}"
    elsif options[:include_all]
      ".*#{Dsu::Support::TimeFormatable.formatted_time(time: time)}.*no entries available for this day"
    end
  end.join('.*')
  regex_string = regex_string.gsub('(', '\(')
  regex_string = regex_string.gsub(')', '\)')
  Regexp.new(regex_string, Regexp::MULTILINE)
end

RSpec.describe Dsu::Support::EntryGroupViewable do
  let(:time) { Time.now }
  let(:times) { [time] }
  let(:options) { build(:configuration).to_h }

  describe '#view_entry_group' do
    subject(:view_entry_group) do
      described_class.view_entry_group(time: time, options: options)
    end

    context 'when the arguments are invalid' do
      context 'when argument :time is not an Time object' do
        let(:time) { :bad }
        let(:expected_error) { /time must be a Time object/ }

        it_behaves_like 'an error is raised'
      end

      context 'when argument :options is not a Hash' do
        let(:options) { :bad }
        let(:expected_error) { /options must be a Hash/ }

        it_behaves_like 'an error is raised'
      end
    end

    context 'when the arguments are valid' do
      before do
        entry_group
      end

      let(:entry_group) { create(:entry_group, :with_entries, time: time) }

      context 'when the entry group does not exist' do
        let(:entry_group) { nil }

        it 'displays nothing' do
          expect { view_entry_group }.to output('').to_stdout
        end
      end

      context 'when the entry group exists and the :includes_all option is false' do
        let(:options) { { include_all: false } }
        let(:expected_output) do
          entry_groups_regex_for(times: times, options: options)
        end

        it 'displays the entry group' do
          expect { view_entry_group }.to output(expected_output).to_stdout
        end
      end

      context 'when the entry group exists and the :includes_all option is true' do
        let(:options) { { include_all: true } }
        let(:expected_output) do
          entry_groups_regex_for(times: times, options: options)
        end

        it 'displays the entry group' do
          expect { view_entry_group }.to output(expected_output).to_stdout
        end
      end

      context 'when the entry group DOES NOT exists and the :includes_all option is false' do
        before do
          entry_group.delete!
        end

        let(:options) { { include_all: false } }

        it 'displays nothing' do
          expect { view_entry_group }.to output('').to_stdout
        end
      end

      context 'when the entry group DOES NOT exists and the :includes_all option is true' do
        before do
          entry_group.delete!
        end

        let(:options) { { include_all: true } }
        let(:expected_output) do
          /.+no entries available for this day.+/
        end

        it "displays 'no entries available...'" do
          expect { view_entry_group }.to output(expected_output).to_stdout
        end
      end
    end
  end

  describe '#view_entry_groups' do
    subject(:view_entry_groups) do
      described_class.view_entry_groups(times: times, options: options)
    end

    let(:times) { [time.yesterday, time, time.tomorrow] }

    context 'when the arguments are invalid' do
      context 'when argument :times is not an Array' do
        let(:times) { :bad }
        let(:expected_error) { /times must be an Array/ }

        it_behaves_like 'an error is raised'
      end

      context 'when argument :options is not a Hash' do
        let(:options) { :bad }
        let(:expected_error) { /options must be a Hash/ }

        it_behaves_like 'an error is raised'
      end
    end

    context 'when the arguments are valid' do
      context 'when there are no entry groups' do
        let(:expected_output) do
          ''
        end

        it 'displays nothing' do
          expect { view_entry_groups }.to output(expected_output).to_stdout
        end
      end

      context 'when there are entry groups' do
        before do
          entry_groups
        end

        let(:entry_groups) do
          times.map do |time|
            create(:entry_group, :with_entries, time: time)
          end
        end

        it 'displays the entry groups' do
          expected_output = entry_groups_regex_for(times: times)
          expect { view_entry_groups }.to output(expected_output).to_stdout
        end
      end

      context 'when not all times have entry groups' do
        before do
          entry_groups
        end

        let(:times) { [time.yesterday, time, time.tomorrow] }
        let(:entry_groups) do
          times.each_with_index.map do |time, index|
            next if index == 1

            create(:entry_group, :with_entries, time: time)
          end
        end

        it 'displays the entry groups' do
          expected_output = entry_groups_regex_for(times: times, options: { include_all: false })
          expect { view_entry_groups }.to output(expected_output).to_stdout
        end
      end
    end
  end
end
