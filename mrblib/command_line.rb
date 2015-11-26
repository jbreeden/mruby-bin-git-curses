module GitDig
class CommandLine < CUI::Window
  attr_accessor :text

  def initialize(*opts)
    super
    @status = nil

    on(CUI::KeyEvent) do |k|
      
    end
  end

  def template
    "$ %-#{self.maxx - 2}s"
  end

  def render
    self.with_color(Colors::DEFAULT) do
      Curses.wmove(@win, 0, 0)
      str = @text.to_s
      Curses.wprintw(@win, template % str)
      Curses.wmove(@win, 0, str.to_s.length + 2)
    end
  end
end
end
