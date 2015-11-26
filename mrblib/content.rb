module GitDig
  class Content < CUI::Window
    include CUI::WindowIO

    def initialize(*opts)
      super
      # Curses.scrollok(@win, true)
      @scroll_top = 0
      @scroll_left = 0
    end

    def current_line_num
      @scroll_top + 1
    end

    def current_line
      @model.lines[@scroll_top]
    end

    def goto_next_line
      self.goto_line(current_line_num + 1)
    end

    def goto_previous_line
      self.goto_line(current_line_num - 1)
    end

    def goto_line(num)
      num = 1 if num < 1

      # Go to the last line, at the most
      num = (num > @model.lines.length) ? @model.lines.length : num

      # Scroll top is 0-based, line numbers are 1-based from "goto" (user) perspective
      @scroll_top = num - 1
    end

    def render
      Curses.wmove(@win, 0, 0)
      self.each_line do |line_num|
        Curses.wmove(@win, line_num, 0)
        paint_line(@model.lines[line_num + @scroll_top])
      end
    end

    # For semantics... rerender will always redraw the entire window,
    # render just happens to for now.
    alias rerender render

    def paint_line(line)
      if line.nil?
        self.with_color(Colors::DEFAULT) do
          Curses.waddstr(@win, " " * self.maxx)
        end
        return nil
      end

      time = line.commit.author_time
      self.with_color(Colors::SHA) do
        Curses.waddstr(@win, "#{line.commit.sha[0..5]} ")
      end
      self.with_color(Colors::TIME) do
        Curses.waddstr(@win, "#{'%02d' % time.day}/#{'%02d' % time.month}/#{time.year} #{'%02d' % time.hour}:#{'%02d' % time.min} ")
      end
      self.with_color(Colors::DEFAULT) do
        Curses.waddstr(@win, "#{'%04d' % line.line_cur}| ")
      end
      self.with_color(Colors::DEFAULT) do
        # - 1 to get the zero-based index of the last char that fits
        visible_range = (0..(self.maxx - self.getx - 1))
        Curses.waddstr(@win, "%-#{self.maxx - self.getx}s" % line.content[visible_range])
      end

      return nil
    end
  end
end
