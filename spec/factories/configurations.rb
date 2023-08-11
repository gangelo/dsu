# frozen_string_literal: true

FactoryBot.define do
  factory :configuration, class: 'Dsu::Models::Configuration' do
    options { {} }

    transient do
      config_hash { nil }
      color_theme { nil }
    end

    initialize_with { Dsu::Models::Configuration.new(options: options) }

    after(:create) do |configuration, evaluator|
      if evaluator.color_theme
        evaluator.color_theme.save! unless evaluator.color_theme.persisted?
        configuration.theme_name = evaluator.color_theme.theme_name
        configuration.save!
      end
    end

    after(:build) do |configuration, evaluator|
      configuration.replace!(config_hash: evaluator.config_hash) if evaluator.config_hash
    end
  end
end
