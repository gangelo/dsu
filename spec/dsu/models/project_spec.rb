# frozen_string_literal: true

RSpec.describe Dsu::Models::Project do
  subject(:project) do
    described_class.new(project_name: project_name, description: description, version: version, options: options)
  end

  shared_examples 'the projects are different' do
    it 'returns false' do
      expect(project == different_project).to be false
    end
  end

  let(:project_name) { 'Test' }
  let(:description) { 'Test project' }
  let(:version) { nil }
  let(:options) { {} }

  describe '#initialize' do
    context 'when the arguments are valid' do
      it 'does not raise an error' do
        expect { project }.not_to raise_error
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

      context 'when project_name is not a string' do
        let(:project_name) { :not_a_string }
        let(:expected_error) { 'project_name is not a String' }

        it_behaves_like 'an error is raised'
      end

      context 'when description is nil' do
        let(:description) { nil }
        let(:expected_error) { 'description is blank' }

        it_behaves_like 'an error is raised'
      end

      context 'when description is an empty string' do
        let(:description) { '' }
        let(:expected_error) { 'description is blank' }

        it_behaves_like 'an error is raised'
      end

      context 'when description is not a string' do
        let(:description) { :not_a_string }
        let(:expected_error) { 'description is not a String' }

        it_behaves_like 'an error is raised'
      end
    end
  end

  describe '#==' do
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

  describe '#hash' do
    it 'returns an Integer' do
      expect(project.hash).to be_a(Integer)
    end
  end

  describe '#to_h' do
    let(:expected_hash) do
      {
        version: project.version,
        project_name: project.project_name,
        description: project.description,
        project_path: project.project_path
      }
    end

    it 'returns a Hash representation of the project' do
      expect(project.to_h).to eq(expected_hash)
    end
  end
end
