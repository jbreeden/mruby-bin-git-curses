module GitCurses
module Colors

  # Available Colors
  # ----------------
  # - MAGENTA
  # - GREEN
  # - WHITE
  # - RED
  # - YELLOW
  # - CYAN
  # - BLUE
  # - BLACK

  def self.color(foreground, background)
    val = self.const_get("#{foreground}_ON_#{background}") rescue nil
    if val
      return val
    end
    @i ||= 0
    @i += 1
    Curses.init_pair(@i, Curses.const_get("COLOR_#{foreground}".to_sym), Curses.const_get("COLOR_#{background}".to_sym))
    self.const_set("#{foreground}_ON_#{background}", Curses.color_pair(@i))
    return Curses.color_pair(@i)
  end

  DEFAULT = color(:WHITE, :BLACK)
  DEFAULT_ALT = color(:BLACK, :WHITE)
  SHA = color(:RED, :BLACK)
  AUTHOR = color(:YELLOW, :BLACK)
  TIME = DEFAULT
  LINE_NO = color(:GREEN, :BLACK)
  SELECTED_LINE = color(:BLACK, :GREEN)
end
end
