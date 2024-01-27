# frozen_string_literal: true

FactoryBot.define do
  factory :delete_presenter, class: 'Dsu::Presenters::Project::DeletePresenter' do
    project_name { 'test' }
    options { {} }

    initialize_with do
      new(project_name: project_name, options: options)
    end

    trait :with_default_project do
      project_name do
        Dsu::Models::Project.default_project.project_name
      end

      with_project
    end

    trait :with_project do
      after(:build) do |_delete_presenter, evaluator|
        project_name = evaluator.project_name
        options = evaluator.options
        build(:project, project_name: project_name, options: options).tap do |project|
          project.save! unless project.exist?
        end
      end
    end
  end
end
