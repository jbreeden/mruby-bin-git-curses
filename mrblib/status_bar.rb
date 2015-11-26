module GitDig
class StatusBar < CUI::Window
  attr_accessor :status

  def initialize(*opts)
    super
    @status = nil
  end

  def template
    # Left justfied, full width
    "%-#{self.maxx}s"
  end

  def render
    self.with_color(Colors::DEFAULT_ALT) do
      Curses.wmove(@win, 0, 0)
      Curses.wprintw(@win, template % @status)
    end
  end
end
end
