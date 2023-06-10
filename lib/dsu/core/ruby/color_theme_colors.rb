# frozen_string_literal: true

module ColorThemeColors
  THEME_COLOR_DEFAULTS = { color: :default, mode: :default, background: :default }.freeze

  # Ensures that default colors and mode are represented in the returned Hash.
  def merge_default_colors
    # TODO: Error checking.
    THEME_COLOR_DEFAULTS.merge(dup)
  end

  def merge_default_colors!
    # TODO: Error checking.
    merge!(merge_default_colors)
  end

  private

  def default_theme_colors
    @default_theme_colors ||= { color: :default, mode: :default, background: :default }
  end
end
