# frozen_string_literal: true

FactoryBot.define do
  factory :migration_service, class: 'Dsu::Migration::Service' do
    options { {} }

    initialize_with { Dsu::Migration::Service.new(options: options) }
  end
end
