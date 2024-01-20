# frozen_string_literal: true

FactoryBot.define do
  factory :create_presenter, class: 'Dsu::Presenters::Project::CreatePresenter' do
    project_name { 'test' }
    description { nil }
    options { {} }

    transient do
      with_project { true }
    end

    initialize_with do
      new(project_name: project_name, description: description, options: options)
    end

    trait :with_project do
      after(:build) do |_create_presenter, evaluator|
        if evaluator.with_project
          build(:project,
            project_name: evaluator.project_name,
            description: evaluator.description,
            options: evaluator.options).tap do |project|
            project.save! unless project.exist?
          end
        end
      end
    end
  end
end
