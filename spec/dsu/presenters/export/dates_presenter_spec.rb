# frozen_string_literal: true

RSpec.describe Dsu::Presenters::Export::DatesPresenter do
  subject(:presenter) do
    strip_escapes(Dsu::Services::StdoutRedirectorService.call do
                    described_class.new(from: from, to: to, options: options).render(response: response)
                  end)
  end

  let(:options) { {} }
  let(:times) { times_for_week_of(Time.now.in_time_zone) }
  let(:from) { times.min }
  let(:to) { times.max }

  describe '#render' do
    context 'when response is falsey' do
      let(:response) { false }

      it 'displays the cancelled message' do
        expect(presenter).to include(I18n.t('subcommands.export.messages.cancelled'))
      end
    end

    context 'when response is true' do
      before do
        times.each do |time|
          create(:entry_group, :with_entries, time: time)
        end
      end

      let(:response) { true }

      it 'displays the exported message' do
        expect(presenter).to include(I18n.t('subcommands.export.messages.exported'))
      end

      it 'displays the exported to message with the file path' do
        regex = /#{I18n.t('subcommands.export.messages.exported_to', file_path: 'x')[...-3]}/
        expect(presenter).to match(regex)
      end
    end
  end

  describe '#display_export_prompt' do
    subject(:presenter) do
      strip_escapes(Dsu::Services::StdoutRedirectorService.call do
                      described_class.new(from: from, to: to, options: options).display_export_prompt
                    end)
    end

    let(:options) { { prompts: { any: true } } }
    let!(:entry_groups) do
      times.each.map do |time|
        create(:entry_group, :with_entries, time: time)
      end
    end

    it 'displays the display_export_prompt' do
      export_prompt = I18n.t('subcommands.export.prompts.export_dates_confirm', from: from.to_date, to: to.to_date, count: entry_groups.count)
      expect(presenter).to include(export_prompt)
    end
  end

  describe '#nothing_to_export?' do
    subject(:presenter) { described_class.new(from: from, to: to, options: options).nothing_to_export? }

    context 'when there is nothing to export' do
      it 'returns true' do
        expect(presenter).to be true
      end
    end

    context 'when there is something to export' do
      before do
        create(:entry_group, :with_entries, time: from)
      end

      it 'returns false' do
        expect(presenter).to be false
      end
    end
  end
end
