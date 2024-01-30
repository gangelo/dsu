# frozen_string_literal: true

RSpec.describe Dsu::Views::Project::Create do
  subject(:create_view) do
    described_class.new(presenter: presenter, options: options)
  end

  before do
    stub_import_prompt(response: response)
  end

  let(:presenter) do
    build(:create_presenter, project_name: project_name, description: description, options: options)
  end
  let(:project_name) { 'xyz' }
  let(:description) { nil }
  let(:options) { nil }
  let(:response) { 'unused' }

  describe '#initialize' do
    context 'when the arguments are valid' do
      it 'does not raise an error' do
        expect { create_view }.to_not raise_error
      end
    end
  end

  describe '#render' do
    context 'when the project already exists' do
      let(:presenter) do
        build(:create_presenter, :with_project, project_name: project_name, description: description, options: options)
      end
      let(:expected_error) do
        "Project \"#{project_name}\" already exists."
      end

      it 'displays the error' do
        expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
          create_view.render
        end.chomp)).to include(expected_error)
      end
    end

    context 'when the project does not exist' do
      context "when the user confirmation is 'y'" do
        let(:response) { 'y' }

        it 'displays the project created message' do
          expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
            create_view.render
          end.chomp)).to include("Created project \"#{project_name}\".")
        end

        it 'creates the project' do
          create_view.render
          expect(Dsu::Models::Project.exist?(project_name: project_name)).to be(true)
        end
      end

      context "when the user confirmation is 'n'" do
        let(:response) { 'n' }

        it 'displays the cancelled message' do
          expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
            create_view.render
          end.chomp)).to include('Cancelled.')
        end

        it 'does not create the project' do
          create_view.render
          expect(Dsu::Models::Project.exist?(project_name: project_name)).to be(false)
        end
      end
    end

    context 'when the project has errors' do
      before do
        allow(presenter).to receive_messages(project_errors?: true,
          project_errors: expected_errors)
      end

      let(:presenter) do
        build(:create_presenter, :with_project, project_name: project_name, description: description, options: options)
      end
      let(:expected_errors) do
        [
          'Project error 1',
          'Project error 2'
        ]
      end

      it 'displays the error' do
        expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
          create_view.render
        end.chomp)).to include(expected_errors.join("\n"))
      end
    end

    context 'when an error is raised that is not rescued' do
      before do
        allow(presenter).to receive(:project_errors?).and_raise(StandardError, expected_error)
      end

      let(:presenter) do
        build(:create_presenter, project_name: project_name, description: description, options: options)
      end
      let(:expected_error) { 'Test error' }

      it 'rescues and displays the error' do
        expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
          create_view.render
        end.chomp)).to include(expected_error)
      end
    end
  end
end
