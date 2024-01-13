# frozen_string_literal: true

FactoryBot.define do
  factory :project, class: 'Dsu::Models::Project' do
    name { 'default' }
    entry_groups { [create(:entry_group, :with_entries)] }
    options { {} }

    initialize_with do
      new(name: name, entry_groups: entry_groups, options: options)
    end

    after(:build) do |_project, _evaluator|
      # TODO: something
    end

    after(:create) do |project, _evaluator|
      #project.write!
    end
  end
end
