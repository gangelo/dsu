# frozen_string_literal: true

RSpec.describe Dsu::Support::ProjectFileSystem do
  subject(:project_file_system) do
    Class.new do
      include Dsu::Support::ProjectFileSystem

      attr_reader :project_name

      def initialize(project_name:)
        @project_name = project_name
      end
    end.new(project_name: project_name)
  end

  let(:project_name) { 'Test' }

  describe '.current_project_name' do
    context 'when the current project file exists' do
      before do
        project_file_system.class.initialize_project(project_name: project_name)
      end

      it 'returns the current project' do
        expect(project_file_system.class.current_project_name).to eq('default')
      end
    end

    context 'when the current project file does not exist' do
      it 'does something'
    end
  end

  describe '#exist?' do
    context 'when the project file exists' do
      before do
        project_file_system.class.initialize_project(project_name: project_name)
        project_file = Dsu::Support::Fileable.project_file_for(project_name: project_name)
        FileUtils.touch(project_file) if project_file.include?(temp_folder)
      end

      it 'returns true' do
        expect(project_file_system.exist?).to be true
      end
    end

    context 'when the project file does not exist' do
      it 'returns false' do
        expect(project_file_system.exist?).to be false
      end
    end
  end

  describe '#project_initialized?' do
    context 'when the project is initialized' do
      before do
        project_file_system.class.initialize_project(project_name: project_name)
      end

      it 'returns true' do
        expect(project_file_system.project_initialized?).to be true
      end
    end

    context 'when the project is not initialized' do
      it 'returns false' do
        expect(project_file_system.project_initialized?).to be false
      end
    end

    context 'when the projects folder does not exist' do
      before do
        project_file_system.class.initialize_project(project_name: project_name)
        projects_folder = Dsu::Support::Fileable.projects_folder
        FileUtils.rm_rf(projects_folder) if projects_folder.include?(temp_folder)
      end

      it 'returns false' do
        expect(project_file_system.project_initialized?).to be false
      end
    end

    context 'when the project folder does not exist' do
      before do
        project_file_system.class.initialize_project(project_name: project_name)
        project_folder = Dsu::Support::Fileable.project_folder_for(project_name: project_name)
        FileUtils.rm_rf(project_folder) if project_folder.include?(temp_folder)
      end

      it 'returns false' do
        expect(project_file_system.project_initialized?).to be false
      end
    end

    context 'when the current project file does not exist' do
      before do
        project_file_system.class.initialize_project(project_name: project_name)
        current_project_file = Dsu::Support::Fileable.current_project_file
        FileUtils.mv(current_project_file, "#{File.basename(current_project_file, File.extname(current_project_file))}.bak")
      end

      it 'returns false' do
        expect(project_file_system.project_initialized?).to be false
      end
    end

    context 'when the project file does not exist' do
      before do
        project_file_system.class.initialize_project(project_name: project_name)
      end

      it 'returns true because project initialized state does not depend on the project file existing' do
        expect(project_file_system.project_initialized?).to be true
      end
    end
  end

  # describe '.project_metadata' do
  #   it 'does something'
  # end

  # describe '.default_project_name' do
  #   it 'does something'
  # end
end
