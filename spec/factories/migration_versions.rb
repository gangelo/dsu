# frozen_string_literal: true

FactoryBot.define do
  factory :migration_version, class: 'Dsu::Models::MigrationVersion' do
    version { nil }
    options { {} }

    trait :with_current_version do
      version { Dsu::Migration::VERSION }
    end

    initialize_with do
      Dsu::Models::MigrationVersion.new(version: version, options: options)
    end

    after(:create) do |migration_version, _evaluator|
      migration_version.save!
    end
  end
end
