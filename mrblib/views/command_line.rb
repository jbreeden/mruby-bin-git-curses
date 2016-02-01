module GitCurses
class CommandLineModel < CUI::Model
  model_attr :prompt, :command, :message, :history

  def initialize
    super()
    self.command = ''
    self.history = []
  end
end

class CommandLine < CUI::Window
  def initialize(opt)
    super(opt)
    @status = nil
    @model ||= CommandLineModel.new
    @model.prompt ||= '$ '
    @model.command ||= ''
    @model.history ||= []
    @input = CUI::TextInput.new({
      begx: begx + model.prompt.length,
      begy: begy + 1,
      cols: width - model.prompt.length
    })

    on('focus') do
      @input.focus
    end

    @model.on(/change/) { @invalid = true }

    @input.on('return') do |e, value|
      trigger('command', value)
    end
  end

  def render
    if @invalid
      @io.in_color(Colors::DEFAULT_ALT) do
        @io.goto(0, 0)
        @io.clear_line
        @io.write_line(model.message) if model.message
      end
      self.in_color(Colors::DEFAULT) do
        @io.goto(1, 0)
        @io.clear_line
        @io.write_line(model.prompt)
        @io.write_line_right(model.command)
      end
      @invalid = false
    end
    @input.render
  end

  def resize(l, c)
    super
    @input.resize(1, c - model.prompt.length)
  end

  def mv(l, c)
    super
    @input.mv(l + 1, c + model.prompt.length)
  end

end
end
