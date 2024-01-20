# frozen_string_literal: true

FactoryBot.define do
  factory :use_presenter, class: 'Dsu::Presenters::Project::UsePresenter' do
    project_name_or_number { 'test' }
    options { {} }

    transient do
      # Define transient attributes here if needed
    end

    initialize_with do
      new(project_name_or_number: project_name_or_number, options: options)
    end

    trait :without_project_name do
      project_name_or_number { nil }
    end

    trait :with_project_name do
      after(:build) do |_use_presenter, evaluator|
        project_name_or_number = evaluator.project_name_or_number
        if /\A\d+\z/.match?(project_name_or_number)
          raise "project name \"#{project_name_or_nmber}\" should not be a number"
        end

        options = evaluator.options
        build(:project, project_name: project_name_or_number, options: options).tap do |project|
          project.save! unless project.exist?
        end
      end
    end

    trait :with_project_number do
      after(:build) do |use_presenter, evaluator|
        project_name = evaluator.project_name_or_number
        raise "project name \"#{project_name}\" should not be a number" if /\A\d+\z/.match?(project_name)

        options = evaluator.options
        project_metadata = Dsu::Models::Project.project_metadata.find do |metadata|
          metadata[:project_name] == project_name
        end
        project_number = if project_metadata
          project_metadata[:project_number]
        else
          build(:project, project_name: project_name, options: options).tap do |project|
            project.save! unless project.exist?
          end.project_number
        end
        use_presenter.project_name_or_number = project_number
      end
    end
  end
end
