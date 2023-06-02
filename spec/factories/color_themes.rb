# frozen_string_literal: true

FactoryBot.define do
  factory :color_theme, class: 'Dsu::Models::ColorTheme' do
    transient do
      save { false }
    end

    theme_name { Dsu::Models::ColorTheme::DEFAULT_THEME_NAME }
    theme_hash { Dsu::Models::ColorTheme::DEFAULT_THEME }

    initialize_with do
      new(theme_name: theme_name, theme_hash: theme_hash)
    end

    after(:build) do |color_theme, evaluator|
      color_theme.save! if evaluator.save
    end
  end
end
