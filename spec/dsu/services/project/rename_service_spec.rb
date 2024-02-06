# frozen_string_literal: true

RSpec.describe Dsu::Services::Project::RenameService do
  subject(:rename_service) do
    described_class.new(
      from_project_name: from_project.project_name,
      to_project_name: to_project.project_name,
      to_project_description: to_project.description,
      options: options
    ).call
  end

  shared_examples 'the "from project" is the current project' do
    it 'is the current project' do
      expect(from_project.current_project?).to be true
    end
  end

  shared_examples 'the "from project" is not the current project' do
    it 'is not the current project' do
      expect(from_project.current_project?).to be false
    end
  end

  shared_examples 'the "from project" is the default project' do
    it 'is the default project' do
      expect(from_project.default_project?).to be true
    end
  end

  shared_examples 'the "from project" is not the default project' do
    it 'is not the default project' do
      expect(from_project.default_project?).to be false
    end
  end

  let(:from_project) { build(:project, project_name: 'From project') }
  let(:to_project) { build(:project, project_name: 'To project') }
  let(:options) { nil }

  describe '#call' do
    context 'when the "from project" does not exist' do
      let(:expected_error) { "Project '#{from_project.project_name}' does not exist." }

      it_behaves_like 'an error is raised'
    end

    context 'when the "to project" already exists' do
      before do
        from_project.save!
        to_project.save!
      end

      let(:expected_error) do
        "Project cannot be renamed to '#{to_project.project_name}' because the project already exists."
      end

      it_behaves_like 'an error is raised'
    end

    context 'when the "from project" is the default project' do
      before do
        from_project.save!
        from_project.default!
      end

      it_behaves_like 'the "from project" is the default project'

      it 'makes the "to project" the default project' do
        rename_service
        expect(to_project.default_project?).to be true
      end

      it 'changes the "from project" to not be the default project' do
        rename_service
        expect(from_project.default_project?).to be false
      end
    end

    context 'when the "from project" is the current project' do
      before do
        from_project.save!
        from_project.use!
      end

      it_behaves_like 'the "from project" is the current project'

      it 'makes the "to project" the current project' do
        rename_service
        expect(to_project.current_project?).to be true
      end

      it 'changes the "from project" to not be the current project' do
        rename_service
        expect(from_project.current_project?).to be false
      end
    end

    context 'when the "from project" is not the current project' do
      before do
        from_project.save!
      end

      it_behaves_like 'the "from project" is not the current project'

      it 'does not change the current project' do
        rename_service
        expect(from_project.current_project?).to be false
      end
    end

    context 'when the "from project" is not the default project' do
      before do
        from_project.save!
      end

      it_behaves_like 'the "from project" is not the default project'

      it 'does not change the default project' do
        rename_service
        expect(to_project.default_project?).to be false
      end
    end

    context 'when the "from project" has entry groups' do
      before do
        from_project.save!
        from_project.use!
        entry_group
      end

      let(:entry_group_time) { Time.now.localtime }
      let(:entry_group) { create(:entry_group, :with_entries, time: entry_group_time) }

      it_behaves_like 'the "from project" is the current project'

      it 'has entry groups' do
        expect(Dsu::Models::EntryGroup.find(time: entry_group_time).entries.count).to eq(2)
      end

      it 'the entry groups become part of the "to project"' do
        rename_service
        expect(to_project.current_project?).to be true
        entry_group = Dsu::Models::EntryGroup.find(time: entry_group_time)
        expect(entry_group.entries.count).to eq(2)
        expect(entry_group.file_path).to include(to_project.project_folder)
      end
    end

    context 'when the "from project" does not have entry groups' do
      before do
        from_project.save!
        from_project.use!
      end

      it_behaves_like 'the "from project" is the current project'

      it 'has entry groups' do
        expect(Dsu::Models::EntryGroup.all.count).to be_zero
      end

      it 'renames the "from project" to the "to project"' do
        rename_service
        expect(to_project.current_project?).to be true
        expect(Dsu::Models::EntryGroup.all.count).to be_zero
      end
    end
  end
end
