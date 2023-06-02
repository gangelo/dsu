# frozen_string_literal: true

# These helpers are used to create and delete the configuration file
# typically before and after every test.
module ColorThemeHelpers
  def create_color_theme!(theme_name:, theme_hash:)
    theme = Dsu::Models::ColorTheme.new(theme_name: theme_name, theme_hash: theme_hash)
    Dsu::Services::ColorTheme::WriterService.new(theme: theme).call!
  end

  def create_default_color_theme!
    theme = Dsu::Models::ColorTheme.default
    Dsu::Services::ColorTheme::WriterService.new(theme: theme).call!
  end

  def delete_color_theme!(theme_name:)
    # TODO: Switch to this service when implemented:
    # Dsu::Services::ColorTheme::DeleterService.new(theme_name: theme_name).call!
    color_theme_class = Dsu::Models::ColorTheme
    if color_theme_class.theme_file_exist?(theme_name: theme_name)
      File.delete(color_theme_class.theme_file(theme_name: theme_name))
    end
  end

  def delete_default_color_theme!
    # TODO: Switch to this service when implemented:
    # Dsu::Services::ColorTheme::DeleterService.new(theme_name: theme_name).call!
    color_theme_class = Dsu::Models::ColorTheme
    if color_theme_class.theme_file_exist?(theme_name: color_theme_class.default.theme_name)
      File.delete(color_theme_class.theme_file(theme_name: color_theme_class.default.theme_name))
    end
  end
end
