# frozen_string_literal: true

RSpec.describe Dsu::Views::Import do
  subject(:import_view) { described_class.new(presenter: presenter, options: options) }

  let(:options) { {} }
  let(:import_file_path) { 'spec/fixtures/files/import.csv' }
  let(:presenter) do
    Dsu::Presenters::Import::AllPresenter.new(import_file_path: import_file_path, options: options)
  end

  describe '#initialize' do
    it 'does not raise an error' do
      expect { import_view }.to_not raise_error
    end
  end

  describe '#render' do
    context 'when all entry groups are being imported' do
      context 'when the import file does not exist' do
        let(:import_file_path) { 'spec/fixtures/files/does-not-exist.csv' }

        it "displays the 'import file does not exist' message" do
          expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
            import_view.render
          end.chomp)).to include('Import file spec/fixtures/files/does-not-exist.csv does not exist.')
        end
      end

      context 'when there is nothing to import' do
        let(:import_file_path) { 'spec/fixtures/files/nothing-to-import.csv' }

        it "displays the 'nothing to import' message" do
          expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
            import_view.render
          end.chomp)).to include('No entry groups to import.')
        end
      end

      context 'when there is something to import' do
        context 'when the user responds with "Y"' do
          before do
            stub_import_prompt(response: 'Y')
          end

          let(:expected_output) do
            <<~OUTPUT
              Entry group for 2023-12-31 imported successfully.
              Entry group for 2024-01-01 imported successfully.
              Entry group for 2024-01-02 imported successfully.
            OUTPUT
          end

          context 'when all imports are successful' do
            it "displays the 'imported successfully' message" do
              expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
                import_view.render
              end.chomp)).to include(expected_output.chomp)
            end
          end
        end

        context 'when the user responds with "n"' do
          before do
            stub_import_prompt(response: 'n')
          end

          it "displays the 'nothing to import' message" do
            expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
              import_view.render
            end.chomp)).to include('Cancelled.')
          end
        end
      end

      context 'when the import file has errors' do
        before do
          stub_import_prompt(response: 'Y')
        end

        let(:import_file_path) { 'spec/fixtures/files/import-with-errors.csv' }
        let(:expected_output) { /The entry groups failed to import/ }

        it "displays the 'imported successfully' message" do
          expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
            import_view.render
          end.chomp)).to match(expected_output)
        end
      end
    end

    describe 'when entry groups are being imported by to/from dates' do
      let(:presenter) { instance_double(Dsu::Presenters::Import::DatesPresenter) }
    end
  end
end
