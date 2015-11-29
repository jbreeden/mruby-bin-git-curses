module GitCurses
class BlameDetailsModel < CUI::Model
  model_attr :line, :status, :key
end

class BlameDetails < CUI::Window
  attr_accessor

  def initialize(*opts)
    super
    @model ||= BlameDetailsModel.new
    @model.on(/change/) { @invalid = true }
  end

  def render
    if @invalid
      self.in_color(Colors::DEFAULT) do
        @io.each_line do |line|
          @io.goto_line(line)
          @io.clear_line
        end

        # The top status line
        @io.goto(0, 0)
        @io.with_attr(Curses::A_UNDERLINE) do
          @io.write_line(model.status)
        end

        if model.key && $DEBUG
          @io.goto_last_col
          @io.write_line_left("Key: #{model.key.key} Key Name: #{model.key.keyname}")
        end

        # The commit data
        @io.goto(1, 0)
        @io.in_bold do
          @io.write_line("Author".ljust(9))
        end
        @io.write_line_right model.line.commit.author if model.line
        @io.goto(2, 0)
        @io.in_bold do
          @io.write_line("Date".ljust(9))
        end
        @io.write_line_right(model.line.commit.author_time.to_s) if model.line
        @io.goto(3, 0)
        @io.in_bold do
          @io.write_line("Summary".ljust(9))
        end
        @io.write_line_right(model.line.commit.summary) if model.line
        @io.goto(4, 0)
        @io.in_bold do
          @io.write_line("Previous".ljust(9))
        end
        @io.write_line_right(model.line.commit.previous) if model.line
      end
      @invalid = false
    end
  end
end
end
