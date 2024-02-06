# frozen_string_literal: true

RSpec.describe Dsu::Views::Project::Rename do
  subject(:rename_view) do
    described_class.new(presenter: presenter, options: options)
  end

  before do
    stub_import_prompt(response: response)
  end

  let(:options) { nil }
  let(:response) { 'none' }
  let(:project) { default_project }
  let(:new_project) do
    build(:project, project_name: 'New project', description: 'New project description')
  end
  let(:presenter) do
    Dsu::Presenters::Project::RenamePresenter.new(project_name: project.project_name,
      new_project_name: new_project.project_name, new_project_description: new_project.description)
  end

  context 'when the project does not exist' do
    let(:project) { build(:project, project_name: "Doesn't exist") }

    let(:expected_error) do
      "Project \"#{project.project_name}\" does not exist."
    end

    it 'displays the project does not exist message' do
      expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
        rename_view.render
      end.chomp)).to include(expected_error)
    end
  end

  it_behaves_like 'a message is displayed when the new project already exists'
  it_behaves_like 'errors are displayed when the new project name or description has errors'
  it_behaves_like "the project is renamed when the user responds 'Y' to the confirmation"
  it_behaves_like "the project is not renamed when the user responds 'n' to the confirmation"
  it_behaves_like 'the error is displayed when an error is raised'
  it_behaves_like 'the project entry groups are moved to the new project'
end
