# frozen_string_literal: true

RSpec.describe Dsu::Views::Project::DeleteByNumber do
  subject(:delete_by_number_view) do
    described_class.new(presenter: presenter, options: options)
  end

  shared_examples 'the project does not exist' do
    it 'does not exist' do
      expect(Dsu::Models::Project.exist?(project_name: project_name)).to be(false)
    end
  end

  shared_examples 'the project exists' do
    it 'exists' do
      expect(Dsu::Models::Project.exist?(project_name: project_name)).to be(true)
    end
  end

  before do
    project
    stub_import_prompt(response: response)
  end

  let(:options) { nil }
  let(:project) do
    create(:project, project_name: project_name, options: options)
  end
  let(:project_name) { 'xyz' }

  describe '#render' do
    let(:presenter) do
      build(:delete_by_number_presenter, project_number: project.project_number, options: options)
    end

    context "when the user confirmation is 'Y'" do
      let(:response) { 'Y' }

      it_behaves_like 'the project exists'

      it 'deletes the project' do
        delete_by_number_view.render
        expect(Dsu::Models::Project.exist?(project_name: project_name)).to be(false)
      end
    end

    context "when the user confirmation is 'n'" do
      let(:response) { 'n' }

      it_behaves_like 'the project exists'

      it 'does not delete the project' do
        delete_by_number_view.render
        expect(Dsu::Models::Project.exist?(project_name: project_name)).to be(true)
      end
    end

    context 'when the project returns errors' do
      before do
        allow(presenter).to receive_messages(project_errors?: true,
          project_errors: expected_errors)
      end

      let(:presenter) do
        build(:delete_by_number_presenter, :with_project_number, project_number: project.project_number, options: options)
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
          delete_by_number_view.render
        end.chomp)).to eq(expected_errors.join("\n"))
      end
    end

    context 'when an error is raised that is not rescued' do
      before do
        allow(presenter).to receive(:project_does_not_exist?).and_raise(StandardError, expected_error)
      end

      let(:presenter) do
        build(:delete_by_number_presenter, project_number: project.project_number, options: options)
      end
      let(:response) { 'unused' }
      let(:expected_error) { 'Test error' }

      it 'captures and displays the error' do
        expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
          delete_by_number_view.render
        end.chomp)).to include(expected_error)
      end
    end

    context 'when the project does not exist' do
      before do
        project.delete!
        allow(presenter).to receive(:project_does_not_exist?).and_return(true)
      end

      let(:presenter) do
        build(:delete_by_number_presenter, project_number: project.project_number, options: options)
      end
      let(:response) { 'unused' }

      it_behaves_like 'the project does not exist'

      context 'when the presenter is using a project that is not the default' do
        let(:expected_error) do
          "A project for number #{project.project_number} does not exist."
        end

        it 'displays the error' do
          expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
            delete_by_number_view.render
          end.chomp)).to include(expected_error)
        end
      end

      context 'when the presenter is using the default project' do
        let(:presenter) do
          build(:delete_by_number_presenter, :with_default_project, options: options)
        end
        let(:expected_error) do
          "A project for number #{default_project.project_number} does not exist."
        end

        it 'displays the error' do
          expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
            delete_by_number_view.render
          end.chomp)).to include(expected_error)
        end
      end
    end
  end
end
