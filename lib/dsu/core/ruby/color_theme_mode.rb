# frozen_string_literal: true

module ColorThemeMode
  def default!
    dup.merge({ mode: :default })
  end

  def bold!
    dup.merge({ mode: :bold })
  end

  def italic!
    dup.merge({ mode: :italic })
  end

  def underline!
    dup.merge({ mode: :underline })
  end

  def blink!
    dup.merge({ mode: :blink })
  end

  def swap!
    dup.merge({ mode: :swap })
  end

  def hide!
    dup.merge({ mode: :hide })
  end

  def mode!(mode)
    dup.merge({ mode: mode })
  end

  def light!
    light_color = "light_#{self[:color].to_s.gsub('light_', '')}".to_sym
    dup.merge({ color: light_color })
  end
end
