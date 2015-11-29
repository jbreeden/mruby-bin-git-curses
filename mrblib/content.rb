module GitCurses
  class Content < CUI::Window
    attr_accessor :current_line

    def initialize(*opts)
      super
      # Should only be written to by goto_line
      @scroll_top = 0
      @scroll_left = 0
      self.current_line = model.lines[@scroll_top]
      @invalid = true

      model.on('clear') { @invalid = true }
      model.on('load') { @invalid = true }
    end

    def current_line_num
      @scroll_top + 1
    end

    def goto_next_line
      self.goto_line(current_line_num + 1)
    end

    def goto_previous_line
      self.goto_line(current_line_num - 1)
    end

    def goto_first_line
      goto_line(1)
    end

    def goto_last_line
      goto_line(model.lines.length)
    end

    def go_page_down
      goto_line(@scroll_top + maxy)
    end

    def go_page_up
      goto_line(@scroll_top - maxy + 2)
    end

    def goto_line(num)
      num = 1 if num < 1

      # Go to the last line, at the most
      num = (num > model.lines.length) ? model.lines.length : num

      # Scroll top is 0-based, line numbers are 1-based from "goto" (user) perspective
      if @scroll_top != num - 1
        @invalid = true
        @scroll_top = num - 1
      end

      old_line = self.current_line
      self.current_line = model.lines[@scroll_top]
      if old_line != self.current_line
        trigger('change:current_line', current_line)
      end
    end

    def bounds_check
      if model.lines.empty?
        goto_line(1)
      elsif @scroll_top + 1 > model.lines.length
        goto_line(model.lines.length)
      end
    end

    def render
      if @invalid
        @io = CUI::WindowIO.new(self)
        bounds_check
        @io.each_line do |line_num|
          @io.goto_line(line_num)
          paint_line(line_num)
        end
        @invalid = false
      end
    end

    def paint_line(line_num)
      line = model.lines[line_num + @scroll_top - 1]
      color_override = line_num == 1 ? Colors::SELECTED_LINE : nil

      if line_num == 0
        @io.goto(0, 0)
        intersection = 34 + model.lines.length.to_s.length
        @io.hline(0, 34 + model.lines.length.to_s.length)
        @io.goto(0, intersection)
        @io.addch(Curses.ACS_TTEE)
        @io.hline(0, @io.cols_right)
      else
        in_color(color_override || Colors::DEFAULT) do
          @io.clear_line
          return nil unless line
          time = line.commit.author_time
          self.in_color(color_override || Colors::SHA) do
            @io.write_line_right(line.commit.sha[0..5])
          end
          @io.go_right
          self.in_color(color_override || Colors::AUTHOR) do
            @io.write_line_right(line.commit.author[0...15].ljust(15))
          end
          @io.go_right
          self.in_color(color_override || Colors::TIME) do
            @io.write_line_right("#{time.year}/#{'%02d' % time.month}/#{'%02d' % time.day}")
          end
          @io.go_right
          self.in_color(color_override || Colors::LINE_NO) do
            @io.write_line_right("%#{model.lines.length.to_s.length}d" % line.line_cur)
          end
          @io.vline(0, 1)
          @io.go_right
          self.in_color(color_override || Colors::DEFAULT) do
            @io.write_line_right(line.content)
          end
        end
      end

      return nil
    end
  end
end
