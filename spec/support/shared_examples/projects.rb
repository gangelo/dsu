# frozen_string_literal: true

shared_examples 'the project does not exist' do
  it 'returns true' do
    expect(!project.exist?).to be true
  end
end

shared_examples 'the project exists' do
  it 'exists and is initialized' do
    expect(project.project_initialized?).to be true
  end
end

shared_examples 'the project is the default project' do
  let(:default_project_name) { Dsu::Models::Configuration.new.default_project }

  it_behaves_like 'the project exists'

  it 'is the default project' do
    expect(project.default_project?).to be true
    expect(project.project_name).to eq(default_project_name)
  end
end

shared_examples 'the project is the current project' do
  let(:current_project_name) { Dsu::Models::Project.current_project_name }

  it_behaves_like 'the project exists'

  it 'is the current project' do
    expect(project.current_project?).to be true
    expect(project.project_name).to eq(current_project_name)
  end
end
