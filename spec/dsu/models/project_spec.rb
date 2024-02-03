# frozen_string_literal: true

RSpec.describe Dsu::Models::Project do
  subject(:project) do
    described_class.new(project_name: project_name, description: description, version: version, options: options)
  end

  let(:project_name) { 'Test' }
  let(:description) { nil }
  let(:version) { nil }
  let(:options) { {} }
  let(:default_project) { described_class.default_project }

  describe '#initialize' do
    context 'when the arguments are valid' do
      it 'does not raise an error' do
        expect { project }.to_not raise_error
      end
    end

    context 'when the arguments are invalid' do
      context 'when version is not an Integer' do
        let(:version) { :not_an_integer }
        let(:expected_error) { 'version is the wrong object type' }

        it_behaves_like 'an error is raised'
      end

      context 'when project_name is nil' do
        let(:project_name) { nil }
        let(:expected_error) { 'project_name is blank' }

        it_behaves_like 'an error is raised'
      end

      context 'when project_name is an empty string' do
        let(:project_name) { '' }
        let(:expected_error) { 'project_name is blank' }

        it_behaves_like 'an error is raised'
      end
    end
  end

  describe 'validations' do
    subject(:project) do
      described_class.new(project_name: project_name, description: description, version: version, options: options).validate!
    end

    it 'validates #description attribute with the DescriptionValidator' do
      expect(described_class).to validate_with_validator(Dsu::Validators::DescriptionValidator)
    end

    it 'validates #description attribute with the ProjectNameValidator' do
      expect(described_class).to validate_with_validator(Dsu::Validators::ProjectNameValidator)
    end

    it 'validates #version attribute with the VersionValidator' do
      expect(described_class).to validate_with_validator(Dsu::Validators::VersionValidator)
    end

    context 'when project_name is less than the min/max length' do
      let(:project_name) { 'x' }
      let(:expected_error) { /Project name is too short/ }

      it_behaves_like 'an error is raised'
    end

    context 'when project_name is greater than the min/max length' do
      let(:project_name) { 'x' * (1 + Dsu::Models::Project::MAX_PROJECT_NAME_LENGTH) }
      let(:expected_error) { /Project name is too long/ }

      it_behaves_like 'an error is raised'
    end

    context 'when description is less than the min/max length' do
      let(:description) { 'x' }
      let(:expected_error) { /Description is too short/ }

      it_behaves_like 'an error is raised'
    end

    context 'when description is greater than the min/max length' do
      let(:description) { 'x' * (1 + Dsu::Models::Project::MAX_DESCRIPTION_LENGTH) }
      let(:expected_error) { /Description is too long/ }

      it_behaves_like 'an error is raised'
    end
  end

  describe '#==' do
    shared_examples 'the projects are different' do
      it 'returns false' do
        expect(project == different_project).to be false
      end
    end

    context 'when the projects are equal' do
      it 'returns true' do
        expect(project == project.clone).to be true
      end
    end

    context 'when the projects are not equal' do
      context 'when the project_name is different' do
        let(:different_project) do
          build(:project,
            project_name: 'different',
            description: description,
            version: version,
            options: options)
        end

        it_behaves_like 'the projects are different'
      end

      context 'when the description is different' do
        let(:different_project) do
          build(:project,
            project_name: project_name,
            description: 'different',
            version: version,
            options: options)
        end

        it_behaves_like 'the projects are different'
      end

      context 'when the version is different' do
        let(:different_project) do
          build(:project,
            project_name: project_name,
            description: description,
            version: 1,
            options: options)
        end

        it_behaves_like 'the projects are different'
      end
    end
  end

  describe 'can_delete?' do
    shared_examples 'the project can be deleted' do
      before do
        project.save!
      end

      it 'is not the only project' do
        expect(described_class.count).to be > 1
      end

      it 'returns true' do
        expect(project.can_delete?).to be true
      end
    end

    shared_examples "the project can't be deleted" do
      it 'returns false' do
        expect(project.can_delete?).to be false
      end
    end

    # rubocop:disable RSpec/RepeatedExampleGroupBody
    context 'when the project exists' do
      it_behaves_like 'the project can be deleted'
    end

    context 'when there is more than one project' do
      it_behaves_like 'the project can be deleted'
    end

    context 'when the project is not the default project' do
      it_behaves_like 'the project can be deleted'
    end
    # rubocop:enable RSpec/RepeatedExampleGroupBody

    context 'when the project does not exist' do
      it_behaves_like "the project can't be deleted"
    end

    context 'when there is only one project' do
      before do
        project_folder = default_project.project_folder
        FileUtils.rm_rf(project_folder) if project_folder.start_with?(temp_folder)

        project.save!
      end

      it_behaves_like "the project can't be deleted"
    end

    context 'when the project is the default project' do
      subject(:project) { default_project }

      it_behaves_like "the project can't be deleted"
    end
  end

  describe '#create' do
    context 'when the project does not exist' do
      it do
        expect(project.persisted?).to be false
      end

      it 'creates the project' do
        project.create
        expect(project.persisted?).to be true
      end
    end

    context 'when the project exists' do
      before do
        project.create
      end

      it do
        expect(project.persisted?).to be true
      end

      it 'does nothing and leaves the project persisted' do
        project.create
        expect(project.persisted?).to be true
      end
    end
  end

  describe '#create!' do
    context 'when the project does not exist' do
      it do
        expect(project.persisted?).to be false
      end

      it 'creates the project' do
        project.create!
        expect(project.persisted?).to be true
      end
    end

    context 'when the project exists' do
      before do
        project.create
      end

      it do
        expect(project.persisted?).to be true
      end

      it 'raises an error' do
        expect { project.create! }.to raise_error(/already exists/)
      end
    end
  end

  describe '#current_project' do
    context 'when the project is the current project' do
      subject(:project) { create(:project, :current_project, project_name: 'new') }

      it 'returns true' do
        expect(project == described_class.current_project).to be true
      end
    end

    context 'when the project is not the current project' do
      subject(:project) { create(:project, project_name: 'new') }

      it 'returns false' do
        expect(project == described_class.current_project).to be false
      end
    end
  end

  describe '#current_project?' do
    subject(:project) { create(:project, project_name: 'new') }

    context 'when the project is the current project' do
      it 'returns true' do
        project.use!
        expect(project.current_project?).to be true
      end
    end

    context 'when the project is not the current project' do
      it 'returns false' do
        expect(project.current_project?).to be false
      end
    end
  end

  describe '#default_project' do
    context 'when the project is the current project' do
      subject(:project) { create(:project, :default_project, project_name: 'new') }

      it 'returns true' do
        expect(project == described_class.default_project).to be true
      end
    end

    context 'when the project is not the current project' do
      subject(:project) { create(:project, project_name: 'new') }

      it 'returns false' do
        expect(project == described_class.default_project).to be false
      end
    end
  end

  describe '#default_project?' do
    subject(:project) { create(:project, project_name: 'new') }

    context 'when the project is the default project' do
      it 'returns true' do
        project.default!
        expect(project.default_project?).to be true
      end
    end

    context 'when the project is not the default project' do
      it 'returns false' do
        expect(project.default_project?).to be false
      end
    end
  end

  describe '#delete' do
    context 'when the project exists' do
      before do
        project.save!
      end

      it 'exists' do
        expect(project.exist?).to be true
      end

      it 'returns true' do
        expect(project.delete).to be true
      end

      it 'deletes the project' do
        project.delete
        expect(project.exist?).to be false
      end
    end

    context 'when the project does not exist' do
      it 'does not exist' do
        expect(project.exist?).to be false
      end

      it 'returns false' do
        expect(project.delete).to be false
      end
    end

    context 'when trying to delete the only project' do
      it 'exists' do
        expect(default_project.exist?).to be true
      end

      it 'is the default project' do
        expect(default_project.default_project?).to be true
      end

      it 'returns false' do
        expect(default_project.delete).to be false
      end

      it 'does not delete the project' do
        default_project.delete
        expect(default_project.exist?).to be true
      end
    end

    context 'when trying to delete the default project' do
      before do
        project.save!
        project.default!
      end

      it 'is the default project' do
        expect(project.default_project?).to be true
      end

      it 'returns false' do
        expect(project.delete).to be false
      end

      it 'does not delete the project' do
        project.delete
        expect(project.exist?).to be true
      end
    end
  end

  describe '#delete!' do
    shared_examples "the project can't be deleted" do
      it 'cannot delete the project' do
        expect { project.delete! }.to raise_error(expected_error)
      end
    end

    context 'when deleting a project that exists' do
      before do
        project.save!
      end

      it 'exists' do
        expect(project.exist?).to be true
      end

      it 'returns true' do
        expect(project.delete!).to be true
      end

      it 'deletes the project' do
        project.delete!
        expect(project.exist?).to be false
      end
    end

    context 'when trying to delete a project that does not exist' do
      let(:expected_error) { /'#{project.project_name}' does not exist/ }

      it_behaves_like "the project can't be deleted"
    end

    context 'when trying to delete the only project' do
      before do
        project_folder = default_project.project_folder
        FileUtils.rm_rf(project_folder) if project_folder.start_with?(temp_folder)

        project.save!
      end

      let(:expected_error) { /'#{project.project_name}' is the only project/ }

      it_behaves_like "the project can't be deleted"
    end

    context 'when trying to delete the default project' do
      before do
        project.save!
        project.default!
      end

      let(:expected_error) { /'#{project.project_name}' is the default project/ }

      it_behaves_like "the project can't be deleted"
    end
  end

  describe '#description' do
    context 'when the description is blank' do
      it "returns '<project name> project' capitalized" do
        project = create(:project, :blank_description, project_name: 'Test')
        expect(project.description).to eq('Test project')
      end
    end

    context 'when the description is provided' do
      it 'returns the description provided' do
        project = create(:project, project_name: 'Test', description: 'Awesome test project')
        expect(project.description).to eq('Awesome test project')
      end
    end
  end

  describe '#hash' do
    it 'returns an Integer' do
      expect(project.hash).to be_a(Integer)
    end
  end

  describe '#persisted?' do
    context 'when the project does not exist' do
      it 'returns false' do
        expect(project.persisted?).to be false
      end
    end

    context 'when the project exists' do
      before do
        project.create
      end

      it 'returns true' do
        expect(project.persisted?).to be true
      end
    end
  end

  describe '#project_file' do
    it 'returns the project file' do
      expected_project_file = Dsu::Support::Fileable.project_file_for(project_name: project.project_name)
      expect(project.project_file).to eq(expected_project_file)
    end
  end

  describe '#project_folder' do
    it 'returns the project folder' do
      expected_project_folder = Dsu::Support::Fileable.project_folder_for(project_name: project.project_name)
      expect(project.project_folder).to eq(expected_project_folder)
    end
  end

  describe '#rename!' do
    let(:new_project_name) { 'new' }

    context 'when the current project exists' do
      before do
        project.save!
      end

      it_behaves_like 'the project exists'

      it 'renames the project and returns true' do
        expect(project.rename!(new_project_name: new_project_name)).to be true
        expect(described_class.exist?(project_name: new_project_name)).to be true
        expect(project.exist?).to be false
      end
    end

    context 'when the current project does not exist' do
      it_behaves_like 'the project does not exist'

      it 'raises an error and does not rename the project' do
        expected_error = /Project file .+ does not exist/
        new_project = build(:project, project_name: new_project_name)
        expect { project.rename!(new_project_name: new_project_name) }.to raise_error(expected_error)
        expect(new_project.exist?).to be false
        expect(project.exist?).to be false
      end
    end

    context 'when the new project exists' do
      before do
        project.save!
      end

      it_behaves_like 'the project exists'

      it 'raises an error and does not rename the project' do
        expected_error = /Project .+ already exists/
        new_project = create(:project, project_name: new_project_name)
        expect { project.rename!(new_project_name: new_project.project_name) }.to raise_error(expected_error)
        expect(new_project.exist?).to be true
        expect(project.exist?).to be true
      end
    end
  end

  describe '#to_h' do
    let(:expected_hash) do
      {
        version: project.version,
        project_name: project.project_name,
        description: project.description
      }
    end

    it 'returns a Hash representation of the project' do
      expect(project.to_h).to eq(expected_hash)
    end
  end

  # describe '#update' do
  # end

  # describe '#update!' do
  # end

  describe 'class methods' do
    shared_examples 'the default project is the default project' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:default_project_name) { Dsu::Models::Configuration.new.default_project }
      let(:expected_default_project) { described_class.default_project }

      it 'exists and is initialized' do
        expect(expected_default_project.project_initialized?).to be true
      end

      it 'is the default project' do
        expect(expected_default_project.default_project?).to be true
      end

      it 'has the default project name' do
        expect(expected_default_project.project_name).to eq default_project_name
      end
    end

    describe '.all' do
      context 'when there are is only the default project' do
        it 'returns an empty Array' do
          expect(described_class.all).to eq([described_class.default_project])
        end
      end

      context 'when there are projects' do
        let!(:projects) do
          [
            described_class.default_project,
            create(:project, project_name: 'project a'),
            create(:project, project_name: 'project b'),
            create(:project, project_name: 'project c')
          ]
        end

        it 'returns an Array of projects' do
          expect(described_class.all).to match_array(projects)
        end
      end
    end

    describe '.default_project' do
      it_behaves_like 'the default project is the default project'
    end

    describe '.find' do
      context 'when the project exists' do
        it_behaves_like 'the default project is the default project'

        it 'returns the project' do
          expect(described_class.find(project_name: described_class.default_project.project_name)).to_not be_nil
        end
      end

      context 'when the project folder does not exist' do
        subject(:project) do
          described_class.find(project_name: project_name)
        end

        before do
          default_project = described_class.default_project
          project_folder = default_project.project_folder
          FileUtils.rm_rf(project_folder) if project_folder.start_with?(temp_folder)
        end

        let(:expected_error) { /Project .* does not exist/ }

        it_behaves_like 'an error is raised'
      end

      context 'when the project file does not exist' do
        subject(:project) do
          described_class.find(project_name: project_name)
        end

        before do
          project = described_class.new(project_name: project_name, description: description, version: version, options: options)
          project.create!
          File.delete(project.project_file) if project.project_file.start_with?(temp_folder)
        end

        let(:expected_error) { /Project file .* does not exist/ }

        it_behaves_like 'an error is raised'
      end
    end

    describe '.find_by_number' do
      context 'when the project is found' do
        it_behaves_like 'the default project is the default project'

        it do
          expect(described_class.all.count).to eq(1)
        end

        it 'returns the project' do
          expect(described_class.find_by_number(project_number: 1)).to_not be_nil
        end
      end

      context 'when the project is not found' do
        it_behaves_like 'the default project is the default project'

        it do
          expect(described_class.all.count).to eq(1)
        end

        it 'returns the project' do
          expect(described_class.find_by_number(project_number: 99)).to be_nil
        end
      end
    end
  end
end
