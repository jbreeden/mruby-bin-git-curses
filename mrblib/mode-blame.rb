$DEBUG = false

module GitCurses
  def self.run(file)
    blame_view = BlameView.new({file: file})
    CUI.screen.add_child(blame_view)
    CUI::EventLoop.run
  end

  class BlameModel < CUI::Model
    model_attr :blame, :revision, :file
  end

  class BlameView < CUI::Window
    BLAME_DETAILS_HEIGHT = 5
    COMMAND_LINE_HEIGHT = 2

    attr_accessor :blame_details, :content, :command_line, :command_interpreter

    def initialize(opt)
      super

      self.model ||= BlameModel.new
      model.file = opt[:file]
      raise "Must specify file option" unless model.file
      model.revision = opt[:revision] || 'HEAD'
      model.blame = Blame.new
      self.command_interpreter = BlameCommandInterpreter.new

      self.blame_details = BlameDetails.new(
        lines: BLAME_DETAILS_HEIGHT,
        begy: 0
      )
      self.content = Content.new(
        model: model.blame,
        begy: BLAME_DETAILS_HEIGHT,
        lines: Curses.LINES - BLAME_DETAILS_HEIGHT - COMMAND_LINE_HEIGHT,
      )
      self.command_line = CommandLine.new(
        lines: COMMAND_LINE_HEIGHT,
        begy: Curses.LINES - COMMAND_LINE_HEIGHT
      )
      add_children(blame_details, content, command_line)

      bind_ui_events
      bind_key_listener
      bind_interpreter_events

      set_details
      command_line.focus

      command_line.model.message = "Loading..."
      CUI::EventLoop.once('render:end') do
        model.blame.load(model.file)
        content.goto_line(0)
        command_line.model.message = "Done."
        set_details
      end
    end

    def layout
      blame_details.resize(BLAME_DETAILS_HEIGHT, CUI.screen.maxx)
      blame_details.mv(0, 0)

      content.resize(Curses.LINES - BLAME_DETAILS_HEIGHT - COMMAND_LINE_HEIGHT, CUI.screen.maxx)
      content.mv(BLAME_DETAILS_HEIGHT, 0)

      command_line.resize(COMMAND_LINE_HEIGHT, CUI.screen.maxx)
      command_line.mv(Curses.LINES - COMMAND_LINE_HEIGHT, 0)
    end

    def set_details
      blame_details.model.status = "#{model.revision}:#{model.file}"
      blame_details.model.line = content.current_line
    end

    def bind_ui_events
      command_line.on('command') do |e, cmd|
        command_interpreter.interpret(cmd)
      end

      content.on('change:current_line') do
        set_details
      end
    end

    def bind_key_listener
      CUI::EventLoop.on(CUI::KeyEvent) do |event|
        case event.keyname
        when '^Q', '^C'
          CUI::EventLoop.exit
        when 'KEY_DOWN'
          content.goto_next_line
        when 'KEY_UP'
          content.goto_previous_line
        when 'KEY_PPAGE'
          content.go_page_up
        when 'KEY_NPAGE'
          content.go_page_down
        when 'KEY_HOME'
          content.goto_first_line
        when 'KEY_END'
          content.goto_last_line
        end
        blame_details.model.key = event
      end
    end

    def bind_interpreter_events
      command_interpreter.on('blame') do |e, sha, file|
        command_line.model.message = "Loading..."
        CUI::EventLoop.once('render:end') do
          model.file = file || model.file
          model.blame.load(model.file, sha)
          model.revision = sha
          command_line.model.message = "Done."
          set_details
        end
      end

      command_interpreter.on('pagedown') do
        content.go_page_down
      end

      command_interpreter.on('pageup') do
        content.go_page_up
      end

      command_interpreter.on('pagestart') do
        content.goto_first_line
      end

      command_interpreter.on('pageend') do
        content.goto_last_line
      end

      command_interpreter.on('goto') do |e, line|
        content.goto_line(line)
      end

      command_interpreter.on('eval') do |e, proc|
        self.instance_eval(&proc)
      end

      command_interpreter.on('error') do |e, error|
        command_line.model.message = "Error: #{error}"
      end
    end

    def previous_revision
      Git.rev_parse "#{content.current_line.commit.sha}^"
    end
  end
end
