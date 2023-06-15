# frozen_string_literal: true

FactoryBot.define do
  factory :configuration, class: 'Dsu::Models::Configuration' do
    initialize_with { Dsu::Models::Configuration.instance }
  end
end
