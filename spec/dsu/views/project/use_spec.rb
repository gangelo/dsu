# frozen_string_literal: true

RSpec.describe Dsu::Views::Project::Use do
  subject(:use_view) do
    described_class.new(presenter: presenter, options: options)
  end

  shared_examples 'the project is the current project' do
    it 'is the current project' do
      expect(Dsu::Models::Project.current_project.project_name).to eq(project_name)
    end
  end

  shared_examples 'the project is not the current project' do
    it 'is not the current project' do
      expect(Dsu::Models::Project.current_project.project_name).to_not eq(project_name)
    end
  end

  before do
    stub_import_prompt(response: response)
  end

  let(:options) { nil }
  let(:project_name) { 'xyz' }

  describe '#render' do
    context 'when using a project name' do
      let(:presenter) do
        build(:use_presenter, :with_project, project_name: project_name, options: options)
      end

      context "when the user confirmation is 'y'" do
        let(:response) { 'y' }

        it_behaves_like 'the project is not the current project'

        it 'uses the project and sets it to the current project' do
          use_view.render
          expect(Dsu::Models::Project.current_project.project_name).to eq(project_name)
        end
      end

      context "when the user confirmation is 'n'" do
        let(:response) { 'n' }

        it_behaves_like 'the project is not the current project'

        it 'does not use the project and does not change the current project' do
          use_view.render
          expect(Dsu::Models::Project.current_project.project_name).to_not eq(project_name)
        end
      end
    end

    context 'when the project returns errors' do
      before do
        allow(presenter).to receive_messages(project_errors?: true,
          project_errors: expected_errors)
      end

      let(:presenter) do
        build(:use_presenter, :with_project, project_name: project_name, options: options)
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
          use_view.render
        end.chomp)).to eq(expected_errors.join("\n"))
      end
    end

    context 'when an error is raised that is not rescued' do
      before do
        allow(presenter).to receive(:project_does_not_exist?).and_raise(StandardError, expected_error)
      end

      let(:presenter) do
        build(:use_presenter, :with_project, project_name: project_name, options: options)
      end
      let(:response) { 'unused' }
      let(:expected_error) { 'Test error' }

      it 'captures and displays the error' do
        expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
          use_view.render
        end.chomp)).to include(expected_error)
      end
    end

    context 'when the project does not exist' do
      before do
        allow(presenter).to receive(:project_does_not_exist?).and_return(true)
      end

      let(:presenter) do
        build(:use_presenter, :with_project, project_name: project_name, options: options)
      end
      let(:response) { 'unused' }

      context 'when the presenter is using a project that is not the default' do
        let(:expected_error) do
          "Project \"#{project_name}\" does not exist."
        end

        it 'displays the error' do
          expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
            use_view.render
          end.chomp)).to include(expected_error)
        end
      end

      context 'when the presenter is using the default project' do
        let(:presenter) do
          build(:use_presenter, :with_default_project, options: options)
        end
        let(:expected_error) do
          "Project \"#{presenter.project_name}\" does not exist."
        end

        it 'displays the error' do
          expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
            use_view.render
          end.chomp)).to include(expected_error)
        end
      end
    end
  end
end
