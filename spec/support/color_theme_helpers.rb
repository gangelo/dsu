# frozen_string_literal: true

# These helpers are used to create and delete the configuration file
# typically before and after every test.
module ColorThemeHelpers
  def create_color_theme!(theme_name:, theme_hash:)
    Dsu::Models::ColorTheme.new(theme_name: theme_name, theme_hash: theme_hash).save!
  end

  def create_default_color_theme!
    Dsu::Models::ColorTheme.default.save!
  end

  def delete_color_theme!(theme_name:)
    raise ArgumentError, 'theme_name is blank' if theme_name.blank?

    if Dsu::Models::ColorTheme.theme_file_exist?(theme_name: theme_name)
      Dsu::Models::ColorTheme.delete!(theme_name: theme_name)
    end
  end

  def delete_default_color_theme!
    Dsu::Models::ColorTheme.default.delete!
  end
end
