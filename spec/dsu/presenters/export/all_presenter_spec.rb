# frozen_string_literal: true

RSpec.describe Dsu::Presenters::Export::AllPresenter do
  subject(:presenter) do
    strip_escapes(Dsu::Services::StdoutRedirectorService.call do
                    described_class.new(options: options).render(response: response)
                  end)
  end

  let(:options) { {} }

  describe '#render' do
    context 'when response is falsey' do
      let(:response) { false }

      it 'displays the cancelled message' do
        expect(presenter).to include(I18n.t('subcommands.export.messages.cancelled'))
      end
    end

    context 'when response is true' do
      before do
        create(:entry_group, :with_entries)
      end

      let(:response) { true }

      it 'displays the exported message' do
        expect(presenter).to include(I18n.t('subcommands.export.messages.exported'))
      end

      it 'displays the exported to message with the file path' do
        export_prompt_regex = /#{I18n.t('subcommands.export.messages.exported_to', file_path: 'x')[...-3]}/
        expect(presenter).to match(export_prompt_regex)
      end
    end
  end

  describe '#display_export_prompt' do
    subject(:presenter) do
      strip_escapes(Dsu::Services::StdoutRedirectorService.call do
                      described_class.new(options: options).display_export_prompt
                    end)
    end

    let(:options) { { prompts: { any: true } } }
    let!(:entry_groups) { [create(:entry_group, :with_entries)] }

    it 'displays the display_export_prompt' do
      export_prompt = I18n.t('subcommands.export.prompts.export_all_confirm', count: entry_groups.count)
      expect(presenter).to include(export_prompt)
    end
  end
end
