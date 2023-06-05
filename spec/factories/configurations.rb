# frozen_string_literal: true

FactoryBot.define do
  factory :configuration, class: 'Dsu::Models::Configuration' do
    transient do
      theme_name { Dsu::Models::ColorTheme::DEFAULT_THEME_NAME }
      theme_hash { Dsu::Models::ColorTheme::DEFAULT_THEME }
      save { false }
      save_theme { false }
    end

    config_hash { Dsu::Models::Configuration::DEFAULT_CONFIGURATION }

    initialize_with do
      new(config_hash: config_hash)
    end

    after(:build) do |configuration, evaluator|
      configuration.theme_name = evaluator.theme_name
      build(:color_theme,
        theme_name: evaluator.theme_name, theme_hash: evaluator.theme_hash, save: evaluator.save_theme)
      configuration.save! if evaluator.save
    end
  end
end
