# frozen_string_literal: true

FactoryBot.define do
  factory :project, class: 'Dsu::Models::Project' do
    project_name { 'default' }
    description { 'Project description' }
    options { {} }
    version { Dsu::Migration::VERSION }

    initialize_with do
      new(project_name: project_name, description: description, version: version, options: options)
    end

    after(:create) do |project, evaluator|
      project.use! if evaluator.make_current_project
      project.default! if evaluator.make_default_project
    end

    transient do
      make_current_project { false }
      make_default_project { false }
    end

    trait :blank_description do
      description { '' }
    end

    trait :current_project do
      make_current_project { true }
    end

    trait :default_project do
      make_default_project { true }
    end
  end
end
