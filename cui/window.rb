module CUI
  class Window
    include CUI::Events
    include CUI::WindowDelegates

    # Instance Methods
    # ----------------

    attr_accessor :win, :model

    def initialize(*opt)
      super() # initialize events
      if opt[0].kind_of?(Hash)
        opt = opt[0]
        lines = opt[:lines] || Curses.LINES
        cols = opt[:cols] || Curses.COLS
        begy = opt[:begy] || 0
        begx = opt[:begx] || 0
        @model = opt[:model]
        @win = Curses.newwin(lines, cols, begy, begx)
        @panel = Curses.new_panel(@win)
      elsif opt[0].kind_of?(Curses::Win)
        @win = opt[0]
        @panel = Curses.new_panel(@win)
      else
        lines = opt[0] || Curses.LINES
        cols = opt[1] || Curses.COLS
        begy = opt[2] || 0
        begx = opt[3] || 0
        @win = Curses.newwin(lines, cols, begy, begx)
        @panel = Curses.new_panel(@win)
      end
      Curses.keypad @win, true
      Curses.nodelay @win, true
      @children = {}
    end

    def io
      CUI::WindowIO.new(self)
    end

    # Called by refresh, before the screen is updated.
    # Override to do any just-in-time output like addch/printw.
    def render
    end

    def rerender
      @invalid = true
      render
    end

    # No easy way to resize windows in panels according to the documentation.
    # Using the recommended workaround. See: http://tldp.org/HOWTO/NCURSES-Programming-HOWTO/panels.html
    def resize(l, c)
      @invalid = true
      y, x = self.gety, self.getx
      begy, begx = self.begy, self.begx
      old_win = Curses.panel_window(@panel)
      @win = Curses.newwin(l, c, begy, begx)
      Curses.replace_panel(@panel, @win)
      Curses.delwin(old_win)
      Curses.keypad @win, true
      Curses.nodelay @win, true
      self.move(y, x)
      Curses.refresh
    end

    def focus
      event_source = CUI::EventLoop.event_source
      CUI::EventLoop.event_source = self
      Curses.show_panel(@panel)
      Curses.top_panel(@panel)
      Curses.wmove(@win, self.gety, self.getx)
      $log.puts("Cursor at #{gety} #{getx}")
      unless focused?
        @focused = true
        if event_source && event_source != self
          event_source.blur
        end
        self.trigger('focus')
      end
    end

    def focused?
      @focused
    end

    def blur
      if focused?
        @focused = false
        if CUI::EventLoop.event_source == self
          CUI::EventLoop.event_source = nil
        end
        self.trigger('blur')
      end
    end

    def hide
      Curses.hide_panel(@panel)
    end

    def show
      Curses.show_panel(@panel)
    end
  end

  def self.screen
    @screen ||= CUI::Window.new(Curses.stdscr)
  end
end
