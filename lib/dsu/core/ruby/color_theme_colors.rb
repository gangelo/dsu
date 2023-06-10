# frozen_string_literal: true

module ColorThemeColors
  DEFAULT_THEME_COLORS = { color: :default, mode: :default, background: :default }.freeze

  # Ensures that default colors and mode are represented in the returned Hash.
  def merge_default_colors
    # TODO: Error checking.
    DEFAULT_THEME_COLORS.merge(dup)
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
