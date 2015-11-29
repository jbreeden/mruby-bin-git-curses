$DEBUG = false

module GitCurses
  BLAME_DETAILS_HEIGHT = 5
  COMMAND_LINE_HEIGHT = 2

  def self.run(file)
    @file = file
    @revision = 'HEAD'
    @blame = Blame.new
    @command_interpreter = BlameCommandInterpreter.new(@blame)
    build_ui
    bind_ui_events
    bind_key_listener
    bind_interpreter_events
    @command_line_window.model.message = "Loading..."
    CUI::EventLoop.once('render:end') do
      @blame.load(@file)
      @content_window.goto_line(0)
      @command_line_window.model.message = "Done."
      set_details
    end
    CUI::EventLoop.run
  end

  def self.build_ui
    @blame_details_window = BlameDetails.new(
      lines: BLAME_DETAILS_HEIGHT,
      begy: 0
    )
    @content_window = Content.new(
      model: @blame,
      begy: BLAME_DETAILS_HEIGHT,
      lines: Curses.LINES - BLAME_DETAILS_HEIGHT - COMMAND_LINE_HEIGHT,
    )
    @command_line_window = CommandLine.new(
      lines: COMMAND_LINE_HEIGHT,
      begy: Curses.LINES - COMMAND_LINE_HEIGHT
    )

    @windows = [@content_window, @blame_details_window, @command_line_window]

    # Since this is a mode, should pull out the event loop
    # init, and just have an `enter` method that adds the appropriate
    # windows to the event loop after clearing the screen
    CUI::EventLoop.windows.clear
    @windows.each do |win|
      CUI::EventLoop.windows.push(win)
    end
    set_details
    @command_line_window.focus
  end

  def self.reflow
    @blame_details_window.resize(BLAME_DETAILS_HEIGHT, CUI.screen.maxx)
    @blame_details_window.mv(0, 0)

    @content_window.resize(Curses.LINES - BLAME_DETAILS_HEIGHT - COMMAND_LINE_HEIGHT, CUI.screen.maxx)
    @content_window.mv(BLAME_DETAILS_HEIGHT, 0)

    @command_line_window.resize(COMMAND_LINE_HEIGHT, CUI.screen.maxx)
    @command_line_window.mv(Curses.LINES - COMMAND_LINE_HEIGHT, 0)
  end

  def self.bind_ui_events
    @command_line_window.on('command') do |e, cmd|
      @command_interpreter.interpret(cmd)
    end

    @content_window.on('change:current_line') do
      set_details
    end
  end

  def self.bind_key_listener
    CUI::EventLoop.on(CUI::KeyEvent) do |event|
      case event.keyname
      when '^Q'
        CUI::EventLoop.exit
      when 'KEY_DOWN'
        @content_window.goto_next_line
      when 'KEY_UP'
        @content_window.goto_previous_line
      when 'KEY_PPAGE'
        @content_window.go_page_up
      when 'KEY_NPAGE'
        @content_window.go_page_down
      when 'KEY_HOME'
        @content_window.goto_first_line
      when 'KEY_END'
        @content_window.goto_last_line
      when 'KEY_RESIZE'
        reflow
      end
      @blame_details_window.model.key = event
    end
  end

  def self.bind_interpreter_events
    @command_interpreter.on('blame') do |e, sha, file|
      @command_line_window.model.message = "Loading..."
      CUI::EventLoop.once('render:end') do
        @file = file || @file
        @blame.load(@file, sha)
        @revision = sha
        @command_line_window.model.message = "Done."
        set_details
      end
    end

    @command_interpreter.on('pagedown') do
      @content_window.go_page_down
    end

    @command_interpreter.on('pageup') do
      @content_window.go_page_up
    end

    @command_interpreter.on('pagestart') do
      @content_window.goto_first_line
    end

    @command_interpreter.on('pageend') do
      @content_window.goto_last_line
    end

    @command_interpreter.on('goto') do |e, line|
      @content_window.goto_line(line)
    end

    @command_interpreter.on('eval') do |e, proc|
      self.instance_eval(&proc)
    end

    @command_interpreter.on('error') do |e, error|
      @command_line_window.model.message = "Error: #{error}"
    end
  end

  def self.set_details
    @blame_details_window.model.status = "#{@revision}:#{@file}"
    @blame_details_window.model.line = @content_window.current_line
  end

  def self.previous_revision
    Git.rev_parse "#{@content_window.current_line.commit.sha}^"
  end
end
