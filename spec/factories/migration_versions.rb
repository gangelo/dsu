# frozen_string_literal: true

FactoryBot.define do
  factory :migration_version, class: 'Dsu::Models::MigrationVersion' do
    version { nil }
    options { {} }

    factory :migration_version_with_current_version do
      version { Dsu::Migration::VERSION }
    end

    initialize_with { Dsu::Models::MigrationVersion.new(version: version, options: options) }
  end
end
