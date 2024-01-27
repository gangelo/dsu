# frozen_string_literal: true

FactoryBot.define do
  factory :use_by_number_presenter, class: 'Dsu::Presenters::Project::UseByNumberPresenter' do
    project_number { 2 }
    options { {} }

    initialize_with do
      new(project_number: project_number, options: options)
    end

    trait :with_default_project do
      project_number do
        Dsu::Models::Project.default_project.project_number
      end

      with_project_number
    end

    trait :with_project_number do
      after(:build) do |use_by_number_presenter, evaluator|
        project_number = evaluator.project_number
        project_metadata = Dsu::Models::Project.project_metadata.find do |metadata|
          metadata[:project_number] == project_number.to_i
        end
        project_number = if project_metadata
          project_metadata[:project_number]
        else
          raise ArgumentError, "project_number #{project_number} is not a valid project number"
        end
        use_by_number_presenter.send(:project_number=, project_number)
      end
    end
  end
end
