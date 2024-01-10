# frozen_string_literal: true

RSpec.describe Dsu::Presenters::EntryGroup::List::DatesPresenter do
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
  let(:times) { [time, time.yesterday] }
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
      context 'when the include_all option is not set' do
        it 'renders nothing' do
          expect(presenter).to be_blank
        end
      end

      context 'when the include_all option is set' do
        let(:options) { { include_all: true } }

        it 'renders something' do
          expect(presenter).to include('no entries available for this day')
        end
      end
    end

    context 'when there is something to list' do
      let(:times) { [time.yesterday, time, time.tomorrow] }
      let!(:entry_groups) do
        [
          create(:entry_group, :with_entries, time: times[0]),
          build(:entry_group, :with_entries, time: times[1]),
          create(:entry_group, :with_entries, time: times[2])
        ]
      end

      context 'when the include_all option is false' do
        it 'renders the entry groups that are presisted' do
          expected_output = [entry_groups[0], entry_groups[2]].map do |entry_group|
            entry_group.entries.map(&:description)
          end.flatten
          expect(presenter).to include(*expected_output)
        end

        it 'does not render the entry groups that are not presisted' do
          expect(presenter).not_to include(*entry_groups[1].entries.map(&:description))
        end
      end

      context 'when the include_all option is true' do
        let(:options) { { include_all: true } }

        it 'renders all the entry groups that are persisted' do
          expected_output = [entry_groups.first, entry_groups.last].map do |entry_group|
            entry_group.entries.map(&:description)
          end.flatten
          expect(presenter).to include(*expected_output)
        end

        it "renders the 'no entries available for this day' message for entry groups that are not persisted" do
          expect(presenter).to include('no entries available for this day')
        end
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
      end).strip
    end

    context 'when the entry groups do not exist for the times and the include_all option is false' do
      let(:expected_message) do
        Dsu::Views::EntryGroup::Shared::NoEntriesToDisplay.new(times: times, options: options).render_as_string
      end

      it do
        expect(presenter.nothing_to_list?).to be(true)
      end

      it 'renders the message' do
        expect(presenter_display_nothing_to_list_message).to eq(strip_escapes(expected_message))
      end
    end

    context 'when the entry groups do not exist for the times and the include_all option is true' do
      let(:options) { { include_all: true } }
      let(:expected_message) do
        Dsu::Views::EntryGroup::Shared::NoEntriesToDisplay.new(times: times, options: options).render_as_string
      end

      it do
        expect(presenter.nothing_to_list?).to be(false)
      end

      it_behaves_like 'the presenter raises an error'
    end

    context 'when there are entry groups for the times' do
      before do
        create(:entry_group, :with_entries, time: times.first)
      end

      it do
        expect(presenter.nothing_to_list?).to be(false)
      end

      it_behaves_like 'the presenter raises an error'
    end
  end
end
