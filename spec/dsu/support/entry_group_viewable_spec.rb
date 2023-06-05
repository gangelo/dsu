# frozen_string_literal: true

RSpec.describe Dsu::Support::EntryGroupViewable do
  let(:time) { Time.now }
  let(:options) { build(:configuration).to_h }

  describe '#view_entry_groups' do
    it 'does something'
  end

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

      after do
        entry_group&.delete
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
          /.+#{Dsu::Support::TimeFormatable.formatted_time(time: time)}.*#{entry_group.entries[0].description}.*#{entry_group.entries[1].description}.*/m
        end

        it 'displays the entry group' do
          expect { view_entry_group }.to output(expected_output).to_stdout
        end
      end

      context 'when the entry group exists and the :includes_all option is true' do
        let(:options) { { include_all: true } }
        let(:expected_output) do
          /.+#{Dsu::Support::TimeFormatable.formatted_time(time: time)}.*#{entry_group.entries[0].description}.*#{entry_group.entries[1].description}.*/m
        end

        it 'displays the entry group' do
          expect { view_entry_group }.to output(expected_output).to_stdout
        end
      end

      context 'when the entry group DOES NOT exists and the :includes_all option is false' do
        before do
          entry_group.delete
        end

        let(:options) { { include_all: false } }

        it 'displays nothing' do
          expect { view_entry_group }.to output('').to_stdout
        end
      end

      context 'when the entry group DOES NOT exists and the :includes_all option is true' do
        before do
          entry_group.delete
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
end
