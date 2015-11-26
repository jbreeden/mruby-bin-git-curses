module GitDig
  HEADER_HEIGHT = 2
  STATUS_BAR_HEIGHT = 1
  COMMAND_LINE_HEIGHT = 1

  def self.run(file)
    @file = file
    @blame = Blame.new
    @blame.load(@file)
    layout_ui
    listen_for_events
    @header_window.loading = false
    CUI::EventLoop.run
  end

  def self.layout_ui
    @header_window = Header.new(lines: HEADER_HEIGHT, model: @blame)
    @content_window = Content.new(
      begin_y: HEADER_HEIGHT,
      lines: Curses.LINES - HEADER_HEIGHT - STATUS_BAR_HEIGHT - COMMAND_LINE_HEIGHT,
      model: @blame
    )
    @status_bar_window = StatusBar.new(
      lines: 1,
      begin_y: Curses.LINES - 2
    )
    @command_line_window = CommandLine.new(
      lines: 1,
      begin_y: Curses.LINES - 1
    )

    @windows = [@header_window, @content_window, @status_bar_window, @command_line_window]

    # Since this is a mode, should pull out the event loop
    # init, and just have an `enter` method that adds the appropriate
    # windows to the event loop after clearing the screen
    CUI::EventLoop.windows.clear
    @windows.each do |win|
      CUI::EventLoop.windows.push(win)
    end
    @command_line_window.focus
  end

  def self.listen_for_events
    # store it, so if we call on again it gets the same
    # handler and doesn't register the callback again.
    @key_listener ||= proc { |event|
      case event.key
      when 'q'.ord, 'Q'.ord
        CUI::EventLoop.exit
      when Curses::KEY_DOWN
        @content_window.goto_next_line
      when Curses::KEY_UP
        @content_window.goto_previous_line
      when 'p'.ord, 'P'.ord
        if can_load_previous_revision?
          @status_bar_window.status = "Loading..."
          CUI::EventLoop.once('render:end') do
            $log.puts "rendered... once?"
            self.load_previous_revision
            @status_bar_window.status = "Loaded!"
          end
        else
          @status_bar_window.status = "No parent revision"
        end
      when Curses::KEY_RESIZE
        layout_ui
      when 'e'.ord, 'E'.ord
        @command_line_window.readline
      end
      @header_window.key = event
    }
    CUI::EventLoop.on(CUI::KeyEvent, &@key_listener)

    @command_listener = proc { |cmd|
      cmd = cmd.sub('command:', '')
      @status_bar_window.status = "Got command: #{cmd}"
    }
    CUI.on(/^command:/, &@command_listener)
  end

  def self.load_previous_revision(&block)
    if can_load_previous_revision?
      @blame.load(@file, previous_revision)
      # @content_window.render
    else
      @status_bar_window.status = "No parent revision"
      @blame
    end
  end

  def self.can_load_previous_revision?
    system("git rev-parse #{previous_revision} 1> /dev/null 2> /dev/null")
  end

  def self.previous_revision
    "#{@content_window.current_line.commit.sha}^"
  end
end
