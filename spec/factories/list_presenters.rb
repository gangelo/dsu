# frozen_string_literal: true

FactoryBot.define do
  factory :list_presenter, class: 'Dsu::Presenters::Project::ListPresenter' do
    options { {} }

    transient do
      project_names { %w[Test1 Test2] }
      without_projects { false }
    end

    initialize_with do
      new(options: options)
    end

    after(:build) do |_list_presenter, evaluator|
      if evaluator.without_projects
        evaluator.project_names.each do |project_name|
          Dsu::Models::Project.exist?(project_name: project_name).tap do |exist|
            raise "without_projects is false and project '#{project_name}' already exist!" if exist
          end
        end
      else
        raise 'project_names must not be empty?' if evaluator.project_names.empty?

        evaluator.project_names.each do |project_name|
          build(:project,
            project_name: project_name,
            options: evaluator.options).tap do |project|
            project.save! unless project.exist?
          end
        end
      end
    end
  end
end
