# frozen_string_literal: true

shared_examples 'a message is displayed when the new project already exists' do
  context 'when the new project already exists' do
    before do
      new_project.save!
    end

    let(:expected_error) do
      "A project for new project name \"#{new_project.project_name}\" already exists."
    end

    it 'displays the new project already exists message' do
      expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
        rename_view.render
      end.chomp)).to include(expected_error)
    end
  end
end

shared_examples 'errors are displayd when the new project name or description has errors' do
  context 'when the new project has errors' do
    let(:new_project) do
      build(:project, project_name: 'New project', description: 'x' * (Dsu::Models::Project::MAX_DESCRIPTION_LENGTH + 1))
    end

    let(:expected_error) do
      /Description is too long/
    end

    it 'displays the new project errors' do
      expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
        rename_view.render
      end.chomp)).to match(expected_error)
    end
  end
end

shared_examples "the project is renamed when the user responds 'Y' to the confirmation" do
  context 'when the user responds to the project rename prompt' do
    context "when the user responds with 'Y'" do
      let(:response) { 'Y' }

      it_behaves_like 'the project exists'

      it 'renames the project' do
        expected_output = "Renamed project \"#{project.project_name}\" to \"#{new_project.project_name}\"."
        expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call { rename_view.render }.chomp)).to match(expected_output)
        expect(project.exist?).to be false
        expect(new_project.exist?).to be true
      end
    end
  end
end

shared_examples "the project is not renamed when the user responds 'n' to the confirmation" do
  context "when the user responds with 'n'" do
    let(:response) { 'n' }

    it_behaves_like 'the project exists'

    it 'does not rename the project' do
      expected_output = 'Cancelled.'
      expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call { rename_view.render }.chomp)).to match(expected_output)
      expect(project.exist?).to be true
      expect(new_project.exist?).to be false
    end
  end
end

shared_examples 'the error is displayed when an error is raised' do
  context 'when an error is raised' do
    before do
      allow(presenter).to receive(:project_does_not_exist?).and_raise('Boom!')
    end

    it_behaves_like 'the project exists'

    it 'displays the error' do
      expected_error = 'Boom!'
      expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call { rename_view.render }.chomp)).to match(expected_error)
    end
  end
end
