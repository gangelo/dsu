# frozen_string_literal: true

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Dsu::Views::Project::RenameByNumber do
  subject(:rename_view) do
    described_class.new(presenter: presenter, options: options)
  end

  before do
    stub_import_prompt(response: response)
  end

  let(:options) { nil }
  let(:response) { 'none' }
  let(:project) { default_project }
  let(:project_number) { project.project_number }
  let(:new_project) do
    build(:project, project_name: 'New project', description: 'New project description')
  end
  let(:presenter) do
    Dsu::Presenters::Project::RenameByNumberPresenter.new(project_number: project_number,
      new_project_name: new_project.project_name, new_project_description: new_project.description)
  end

  context 'when a project for the project number does not exist' do
    let(:project_number) { 99 }

    let(:expected_error) do
      "A project for number #{project_number} does not exist."
    end

    it 'displays the project for project number does not exist message' do
      expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
        rename_view.render
      end.chomp)).to include(expected_error)
    end
  end

  it_behaves_like 'a message is displayed when the new project already exists'
  it_behaves_like 'errors are displayd when the new project name or description has errors'
  it_behaves_like "the project is renamed when the user responds 'Y' to the confirmation"
  it_behaves_like "the project is not renamed when the user responds 'n' to the confirmation"
  it_behaves_like 'the error is displayed when an error is raised'
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
