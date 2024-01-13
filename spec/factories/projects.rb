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
  end
end
