# frozen_string_literal: true

RSpec.describe Dsu::Views::Project::UseByNumber do
  subject(:use_by_number_view) do
    described_class.new(presenter: presenter, options: options)
  end

  before do
    stub_import_prompt(response: response)
  end

  let(:options) { nil }
  let(:project) { create(:project, project_name: 'xyz', options: options) }

  describe '#render' do
    context 'when the project exists' do
      let(:presenter) do
        build(:use_by_number_presenter, project_number: project.project_number, options: options)
      end

      context "when using a project number and user confirmation is 'Y'" do
        let(:response) { 'Y' }

        it_behaves_like 'the project is not the current project'

        it 'uses the project and sets it to the current project' do
          use_by_number_view.render
          expect(project.current_project?).to be true
        end
      end

      context "when using a project number and user confirmation is 'n'" do
        let(:response) { 'n' }

        it_behaves_like 'the project is not the current project'

        it 'does not use the project and does not change the current project' do
          use_by_number_view.render
          expect(project.current_project?).to be false
        end
      end

      context 'when trying to use the current project' do
        before do
          project.use!
        end

        let(:response) { 'Y' }

        it 'displays the project is already the current project message' do
          expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
            use_by_number_view.render
          end.chomp)).to eq("Project \"#{project.project_name}\" is already the current project.")
        end
      end
    end

    context 'when the project returns errors' do
      before do
        allow(presenter).to receive_messages(project_errors?: true, project_errors: expected_errors)
      end

      let(:presenter) do
        build(:use_by_number_presenter, project_number: project.project_number, options: options)
      end
      let(:response) { 'unused' }
      let(:expected_errors) do
        [
          'Project error 1',
          'Project error 2'
        ]
      end

      it 'displays the errors' do
        expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
          use_by_number_view.render
        end.chomp)).to eq(expected_errors.join("\n"))
      end
    end

    context 'when an error is raised that is not rescued' do
      before do
        allow(presenter).to receive(:project_does_not_exist?).and_raise(StandardError, expected_error)
      end

      let(:presenter) do
        build(:use_by_number_presenter, project_number: project.project_number, options: options)
      end
      let(:response) { 'unused' }
      let(:expected_error) { 'Test error' }

      it 'captures and displays the error' do
        expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
          use_by_number_view.render
        end.chomp)).to include(expected_error)
      end
    end

    context 'when the project does not exist' do
      before do
        allow(presenter).to receive(:project_does_not_exist?).and_return(true)
      end

      let(:presenter) { build(:use_by_number_presenter, options: options) }
      let(:response) { 'unused' }

      context 'when the presenter is using a project number' do
        before do
          allow(presenter).to receive(:use_by_project_number?).and_return(true)
        end

        let(:expected_error) { "A project for number #{presenter.project_number} does not exist." }

        it 'displays the error' do
          expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
            use_by_number_view.render
          end.chomp)).to include(expected_error)
        end
      end

      context 'when the presenter is using a project that is not the default' do
        let(:expected_error) do
          "A project for number #{presenter.project_number} does not exist."
        end

        it 'displays the error' do
          expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
            use_by_number_view.render
          end.chomp)).to include(expected_error)
        end
      end

      context 'when the presenter is using the default project' do
        let(:presenter) do
          build(:use_by_number_presenter, :with_default_project, options: options)
        end
        let(:expected_error) do
          "A project for number #{presenter.project_number} does not exist."
        end

        it 'displays the error' do
          expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
            use_by_number_view.render
          end.chomp)).to include(expected_error)
        end
      end
    end
  end
end
