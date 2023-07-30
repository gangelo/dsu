# frozen_string_literal: true

FactoryBot.define do
  factory :configuration, class: 'Dsu::Models::Configuration' do
    transient do
      config_hash { nil }
    end

    initialize_with { Dsu::Models::Configuration.instance }

    after(:create) do |configuration, evaluator|
      if evaluator.config_hash
        configuration.replace!(config_hash: evaluator.config_hash)
        configuration.write
      else
        configuration.replace!(config_hash: configuration.class::DEFAULT_CONFIGURATION)
      end
    end

    after(:build) do |configuration, evaluator|
      configuration.replace!(config_hash: evaluator.config_hash) if evaluator.config_hash
    end
  end
end
