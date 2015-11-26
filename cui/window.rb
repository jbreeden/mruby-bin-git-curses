module CUI
class Window
  include CUI::Events

  # Class Macros
  # ------------

  def self.win_delegate(name, _alias=nil)
    self.define_method(name) do |*args|
      Curses.send(name, @win, *args)
    end
    if _alias
      self.alias_method(_alias, name)
    end
  end

  def self.io_mode_handlers(on, off)
    self.define_method(on) do
      @io_mode_init_routines.delete(off)
      @io_mode_init_routines.push(on)
      Curses.send(on) if focused?
    end
    self.define_method(off) do
      @io_mode_init_routines.delete(on)
      @io_mode_init_routines.push(off)
      Curses.send(off) if focused?
    end
  end

  # Instance Methods
  # ----------------

  attr_accessor :win,
    :model

  def initialize(*opt)
    super() # initialize events
    if opt[0].kind_of?(Hash)
      opt = opt[0]
      lines = opt[:lines] || Curses.LINES
      cols = opt[:cols] || Curses.COLS
      begin_y = opt[:begin_y] || 0
      begin_x = opt[:begin_x] || 0
      @model = opt[:model]
      @win = Curses.newwin(lines, cols, begin_y, begin_x)
    elsif opt[0].kind_of?(Curses::Win)
      @win = opt[0]
    else
      lines = opt[0] || Curses.LINES
      cols = opt[1] || Curses.COLS
      begin_y = opt[2] || 0
      begin_x = opt[3] || 0
      @win = Curses.newwin(lines, cols, begin_y, begin_x)
    end
    @io_mode_init_routines = []
    keypad true
    nodelay true
    nocbreak
    noecho
    raw
    noqiflush
  end

  # Called before `Curses.doupdate` by the event loop
  # to write this window to the virtual screen.
  # NO NEED TO OVERWRITE
  def refresh
    render
    Curses.wnoutrefresh(@win)
  end

  # Called by refresh, before the screen is updated.
  # Override to do any just-in-time output like addch/printw.
  def render
  end

  win_delegate :getmaxy, :maxy
  win_delegate :getmaxx, :maxx
  win_delegate :getcury, :gety
  win_delegate :getcurx, :getx
  win_delegate :meta
  win_delegate :intrflush
  win_delegate :keypad
  win_delegate :nodelay
  win_delegate :notimeout
  win_delegate :wtimeout
  io_mode_handlers :cbreak, :nocbreak
  io_mode_handlers :echo, :noecho
  io_mode_handlers :raw, :noraw
  io_mode_handlers :qiflush, :noqiflush

  def focus
    unless focused?
      CUI::EventLoop.event_source.blur if CUI::EventLoop.event_source
      @focused = true
      Curses.wmove(@win, self.gety, self.getx)
      CUI::EventLoop.event_source = self
      @io_mode_init_routines.each do |mode|
        Curses.send(mode)
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
      CUI::EventLoop.event_source = nil if CUI::EventLoop.event_source == self
      self.trigger('blur')
    end
  end

  def in_color(color)
    Curses.wattron(@win, color)
    yield if block_given?
    Curses.wattron(@win, color)
  end
  alias with_color in_color
end
end
