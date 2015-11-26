module GitDig
class Header < CUI::Window
  attr_accessor :loading,
    :status,
    :loading,
    :key

  def template
    return <<EOS
^P: Blame Parent
%{status} Key: %{key} Key Name: %{keyname}
EOS
  end

  def initialize(*opts)
    super
    @loading = false
  end

  def loading=(val)
    @loading = val
    if val
      status = 'Loading...'
    else
      status = 'Loaded!'
    end
  end

  def key=(val)
    @key = val
  end

  def render
    render_background
    with_color(Colors::DEFAULT_ALT) do
      Curses.wmove(@win, 0, 0)
      Curses.wprintw(@win, template % {
        status: @status,
        key: @key,
        keyname: @key.kind_of?(CUI::KeyEvent) ? @key.keyname : nil,
      })
    end
  end

  def render_background
    with_color(Colors::DEFAULT_ALT) do
      Curses.wmove(@win, 0, 0)
      (0...self.maxy).each do |line|
        Curses.mvwprintw(@win, line, 0, (' ' * self.maxx))
      end
    end
  end
end
end
