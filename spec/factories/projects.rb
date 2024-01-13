# frozen_string_literal: true

FactoryBot.define do
  factory :project, class: 'Dsu::Models::Project' do
    project_name { 'default' }
    options { {} }

    initialize_with do
      new(project_name: project_name, options: options)
    end
  end
end
