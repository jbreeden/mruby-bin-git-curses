module GitDig
module Colors
  Curses.init_pair(1, Curses::COLOR_WHITE, Curses::COLOR_BLACK)
  WHITE_ON_BLACK = Curses.color_pair(1)

  Curses.init_pair(2, Curses::COLOR_BLACK, Curses::COLOR_WHITE)
  BLACK_ON_WHITE = Curses.color_pair(2)

  Curses.init_pair(3, Curses::COLOR_RED, Curses::COLOR_BLACK)
  RED_ON_BLACK = Curses.color_pair(3)

  Curses.init_pair(4, Curses::COLOR_BLUE, Curses::COLOR_BLACK)
  BLUE_ON_BLACK = Curses.color_pair(4)

  DEFAULT = WHITE_ON_BLACK
  DEFAULT_ALT = BLACK_ON_WHITE
  SHA = RED_ON_BLACK
  TIME = BLUE_ON_BLACK
end
end
