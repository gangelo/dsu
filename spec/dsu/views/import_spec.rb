# frozen_string_literal: true

RSpec.describe Dsu::Views::Import do
  subject(:import_view) { described_class.new(presenter: presenter, options: options) }

  let(:options) { {} }
  let(:presenter) { instance_double(Dsu::Presenters::Import::AllPresenter) }

  describe '#initialize' do
    it 'does not raise an error' do
      expect { import_view }.to_not raise_error
    end
  end

  describe '#render' do
    context 'when all entry groups are being imported' do
      let(:presenter) { instance_double(Dsu::Presenters::Import::AllPresenter) }

      context 'when the import file does not exist' do
        before do
          allow(presenter).to receive_messages(
            import_file_path: 'input_file.csv',
            import_file_path_exist?: false
          )
        end

        it "displays the 'import file does not exist' message" do
          expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
            import_view.render
          end.chomp)).to include('Import file input_file.csv does not exist.')
        end
      end

      context 'when there is nothing to import' do
        before do
          allow(presenter).to receive_messages(
            nothing_to_import?: true,
            import_file_path_exist?: true
          )
        end

        it "displays the 'nothing to import' message" do
          expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
            import_view.render
          end.chomp)).to include('No entry groups to import.')
        end
      end

      context 'when there is something to import' do
        before do
          allow($stdin).to receive(:getch).and_return(response)
        end

        context 'when the user responds with "Y"' do
          before do
            allow(presenter).to receive_messages(
              nothing_to_import?: false,
              import_file_path_exist?: true,
              import_entry_groups_count: 1,
              project_name: 'current_project_name',
              import_messages: import_messages,
              respond: import_messages
            )
          end

          let(:response) { 'Y' }

          context 'when all imports are successful' do
            let(:import_messages) { { '2024-01-01' => [] } } # rubocop:disable Style/StringHashKeys

            it "displays the 'imported successfully' message" do
              expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
                import_view.render
              end.chomp)).to include('Entry group for 2024-01-01 imported successfully')
            end
          end

          context 'when the imports have errors' do
            let(:import_messages) { { '2024-01-01' => %w[error] } } # rubocop:disable Style/StringHashKeys

            it "displays the 'imported successfully' message" do
              expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
                import_view.render
              end.chomp)).to include('Entry group for 2024-01-01 imported with an error: error')
            end
          end
        end

        context 'when the user responds with "n"' do
          before do
            allow(presenter).to receive_messages(
              nothing_to_import?: false,
              import_file_path_exist?: true,
              import_entry_groups_count: 1,
              project_name: 'current_project_name',
              respond: false
            )
          end

          let(:response) { 'n' }

          it "displays the 'nothing to import' message" do
            expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
              import_view.render
            end.chomp)).to include('Cancelled.')
          end
        end
      end

      context 'when the presenter raises an error' do
        before do
          allow(presenter).to receive(:import_file_path_exist?).and_raise('Boom!')
        end

        it 'resques and displays the error' do
          expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
            import_view.render
          end.chomp)).to include('Boom!')
        end
      end
    end

    describe 'when entry groups are being imported by to/from dates' do
      let(:presenter) { instance_double(Dsu::Presenters::Import::DatesPresenter) }
    end
  end
end
