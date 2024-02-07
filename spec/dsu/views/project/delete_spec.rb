# frozen_string_literal: true

RSpec.describe Dsu::Views::Project::Delete do
  subject(:delete_view) do
    described_class.new(presenter: presenter, options: options)
  end

  let(:options) { nil }
  let(:project_name) { 'xyz' }
  let(:project) { build(:project, project_name: project_name, options: options) }

  describe '#render' do
    let(:presenter) do
      build(:delete_presenter, project_name: project_name, options: options)
    end

    context "when the user confirmation is 'Y'" do
      before do
        project.save!
        stub_import_prompt(response: response)
      end

      let(:response) { 'Y' }

      it_behaves_like 'the project exists'

      it 'deletes the project' do
        delete_view.render
        expect(Dsu::Models::Project.exist?(project_name: project_name)).to be(false)
      end
    end

    context "when the user confirmation is 'n'" do
      before do
        project.save!
        stub_import_prompt(response: response)
      end

      let(:response) { 'n' }

      it_behaves_like 'the project exists'

      it 'does not delete the project' do
        delete_view.render
        expect(Dsu::Models::Project.exist?(project_name: project_name)).to be(true)
      end
    end

    context 'when the project returns errors' do
      before do
        allow(presenter).to receive_messages(project_errors?: true,
          project_errors: expected_errors)
      end

      let(:presenter) do
        build(:delete_presenter, :with_project, project_name: project_name, options: options)
      end
      let(:response) { 'unused' }
      let(:expected_errors) do
        [
          'Project error 1',
          'Project error 2'
        ]
      end

      it 'displays the errors' do
        expect(capture_stdout_and_strip_escapes do
          delete_view.render
        end.chomp).to eq(expected_errors.join("\n"))
      end
    end

    context 'when an error is raised that is not rescued' do
      before do
        allow(presenter).to receive(:project_does_not_exist?).and_raise(StandardError, expected_error)
      end

      let(:presenter) do
        build(:delete_presenter, project_name: project_name, options: options)
      end
      let(:expected_error) { 'Test error' }

      it 'captures and displays the error' do
        expect(capture_stdout_and_strip_escapes do
          delete_view.render
        end.chomp).to include(expected_error)
      end
    end

    context 'when the project does not exist' do
      before do
        allow(presenter).to receive(:project_does_not_exist?).and_return(true)
      end

      let(:presenter) do
        build(:delete_presenter, project_name: project_name, options: options)
      end

      it_behaves_like 'the project does not exist'

      context 'when the presenter is using a project that is not the default' do
        let(:expected_error) do
          "Project \"#{project_name}\" does not exist."
        end

        it 'displays the error' do
          expect(capture_stdout_and_strip_escapes do
            delete_view.render
          end.chomp).to include(expected_error)
        end
      end

      context 'when the presenter is using the default project' do
        let(:presenter) do
          build(:delete_presenter, :with_default_project, options: options)
        end
        let(:expected_error) do
          "Project \"#{presenter.project_name}\" does not exist."
        end

        it 'displays the error' do
          expect(capture_stdout_and_strip_escapes do
            delete_view.render
          end.chomp).to include(expected_error)
        end
      end
    end

    context 'when the project is the default project' do
      before do
        project
      end

      let(:project) { create(:project, :default_project, project_name: project_name, options: options) }

      it_behaves_like 'the project exists'

      it "displays the 'cannot delete the default project' message" do
        expect(capture_stdout_and_strip_escapes do
          delete_view.render
        end).to match(/Project '#{project_name}' is the default project.+ Change to a different default project/)
        expect(project.exist?).to be(true)
      end
    end
  end
end
