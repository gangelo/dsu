# frozen_string_literal: true

RSpec.describe Dsu::Views::Project::List do
  subject(:list_view) do
    described_class.new(presenter: presenter, options: options)
  end

  let(:presenter) do
    build(:list_presenter, options: options)
  end
  let(:options) { nil }

  describe '#initialize' do
    context 'when the arguments are valid' do
      it 'does not raise an error' do
        expect { list_view }.to_not raise_error
      end
    end
  end

  describe '#render' do
    context 'when there are projects to list' do
      let(:presenter) do
        build(:list_presenter, options: options)
      end
      let(:expected_project_list) do
        [
          "1. #{default_project.project_name} * * #{default_project.description}",
          '2. Test1 Test1 project',
          '3. Test2 Test2 project'
        ]
      end

      it 'lists the projects' do
        expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
          list_view.render
        end.chomp).gsub(/\s{2,}/, ' ')).to include(expected_project_list.join(' '))
      end
    end

    context 'when there are no projects to list' do
      before do
        allow(presenter.projects).to receive(:none?).and_return(true)
      end

      it 'displays the no projects to list message' do
        expect(strip_escapes(Dsu::Services::StdoutRedirectorService.call do
          list_view.render
        end.chomp)).to include('No projects are available to list.')
      end
    end
  end
end
