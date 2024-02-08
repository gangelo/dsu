# frozen_string_literal: true

FactoryBot.define do
  factory :color_theme, class: 'Dsu::Models::ColorTheme' do
    theme_name { Dsu::Models::ColorTheme::DEFAULT_THEME_NAME.dup }
    theme_hash { Dsu::Models::ColorTheme::DEFAULT_THEME.dup }

    initialize_with do
      unless theme_name == Dsu::Models::ColorTheme::DEFAULT_THEME_NAME
        theme_hash[:description] = "#{theme_name.capitalize} theme"
      end
      new(theme_name: theme_name, theme_hash: theme_hash)
    end
  end
end
