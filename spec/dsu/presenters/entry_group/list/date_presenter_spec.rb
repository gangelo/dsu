# frozen_string_literal: true

RSpec.describe Dsu::Presenters::EntryGroup::List::DatePresenter do
  subject(:presenter) do
    described_class.new(times: times, options: options)
  end

  shared_examples 'the presenter raises an error' do
    let(:expected_error) do
      'display_nothing_to_list_message called when there are entries to display'
    end

    it 'raises an error' do
      expect { presenter_display_nothing_to_list_message }.to raise_error(expected_error)
    end
  end

  let(:time) { Time.now.in_time_zone }
  let(:times) { [time] }
  let(:options) { {} }

  describe '#initialize' do
    context 'when arguments are valid' do
      it_behaves_like 'no error is raised'
    end

    context 'when argument :times is not an Array' do
      let(:times) { :bad }
      let(:expected_error) { 'times must be an Array' }

      it_behaves_like 'an error is raised'
    end

    context 'when argument :options is not a Hash' do
      let(:options) { :bad }
      let(:expected_error) { 'options must be a Hash' }

      it_behaves_like 'an error is raised'
    end
  end

  describe '#render' do
    subject(:presenter) do
      strip_escapes(Dsu::Services::StdoutRedirectorService.call do
        described_class.new(times: times, options: options).render
      end)
    end

    context 'when there is nothing to list' do
      it "renders the 'no entries available for this day' message" do
        expect(presenter).to include('no entries available for this day')
      end
    end

    context 'when there is something to list' do
      let!(:entry_groups) do
        [
          create(:entry_group, :with_entries, time: times.min),
          create(:entry_group, :with_entries, time: times.max)
        ]
      end
      let(:times) { [time, time.yesterday] }

      it 'renders the entry groups' do
        expected_output = entry_groups.map do |entry_group|
          entry_group.entries.map(&:description)
        end.flatten
        expect(presenter).to include(*expected_output)
      end
    end
  end

  describe '#display_nothing_to_list_message' do
    subject(:presenter) do
      described_class.new(times: times, options: options)
    end

    let(:presenter_display_nothing_to_list_message) do
      strip_escapes(Dsu::Services::StdoutRedirectorService.call do
        presenter.display_nothing_to_list_message
      end)
    end

    context 'when there is only one time passed in the array' do
      context 'when there is no entry group for the date' do
        it do
          expect(presenter.nothing_to_list?).to be(false)
        end

        it_behaves_like 'the presenter raises an error'
      end

      context 'when there is an entry group for the date' do
        before do
          create(:entry_group, :with_entries, time: times.first)
        end

        it do
          expect(presenter.nothing_to_list?).to be(false)
        end

        it_behaves_like 'the presenter raises an error'
      end
    end

    context 'when there is more than one time passed in the array' do
      let(:times) { [time, time.yesterday] }

      context 'when there are entry groups for the times' do
        it do
          expect(presenter.nothing_to_list?).to be(false)
        end

        it_behaves_like 'the presenter raises an error'
      end

      context 'when there is at least one entry group for the times' do
        before do
          create(:entry_group, :with_entries, time: times.min)
          create(:entry_group, :with_entries, time: times.max)
        end

        it do
          expect(presenter.nothing_to_list?).to be(false)
        end

        it_behaves_like 'the presenter raises an error'
      end
    end
  end
end
