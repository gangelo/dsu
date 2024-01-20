# rubocop:disable RSpec/MultipleMemoizedHelpers
# frozen_string_literal: true

RSpec.describe Dsu::Views::Project::Create do
  subject(:create_view) do
    described_class.new(presenter: presenter, options: options)
  end

  let(:presenter) do
    build(:create_presenter, project_name: project_name, description: description, options: options)
  end
  let(:project_name) { 'xyz' }
  let(:description) { nil }
  let(:options) { nil }
  let(:response) { 'unused' }

  describe '#initialize' do
    context 'when the arguments are valid' do
      it 'does not raise an error' do
        expect { create_view }.to_not raise_error
      end
    end
  end

  describe '#render' do
    context 'when the project has errors' do
      before do
        allow(presenter).to receive_messages(project_errors?: true,
          project_errors: expected_errors)
      end

      let(:presenter) do
        build(:create_presenter, :with_project, project_name: project_name, description: description, options: options)
      end
      let(:expected_errors) do
        [
          'Project error 1',
          'Project error 2'
        ]
      end

      it 'displays the error' do
        expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
          create_view.render
        end.chomp)).to include(expected_errors.join("\n"))
      end
    end

    context 'when the project already exists' do
      # before do
      #   allow(presenter).to receive_messages(project_already_exists?: true)
      # end

      let(:presenter) do
        build(:create_presenter, :with_project, project_name: project_name, description: description, options: options)
      end
      let(:expected_error) do
        "Project \"#{project_name}\" already exists."
      end

      it 'displays the error' do
        expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
          create_view.render
        end.chomp)).to include(expected_error)
      end
    end
  end
end

# rubocop:enable RSpec/MultipleMemoizedHelpers
