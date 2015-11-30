$DEBUG = false

module GitCurses
  def self.run(file, rev)
    blame_view = BlameView.new({file: file, revision: rev})
    CUI.screen.add_child(blame_view)
    CUI.run
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
      CUI.once('render:end') do
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
      CUI.on(CUI::KeyEvent) do |event|
        case event.keyname
        when '^Q', '^C'
          CUI.exit
        when 'KEY_DOWN', '^N'
          content.goto_next_line
          command_line.model.message = ""
        when 'KEY_UP', '^P'
          content.goto_previous_line
          command_line.model.message = ""
        when 'KEY_PPAGE'
          content.go_page_up
          command_line.model.message = ""
        when 'KEY_NPAGE'
          content.go_page_down
          command_line.model.message = ""
        when 'KEY_HOME'
          content.goto_first_line
          command_line.model.message = ""
        when 'KEY_END'
          content.goto_last_line
          command_line.model.message = ""
        end
        blame_details.model.key = event
      end
    end

    def bind_interpreter_events
      command_interpreter.on('blame') do |e, sha, file|
        blame(sha, file)
      end

      command_interpreter.on('blame_head') do |e|
        blame('head')
      end

      command_interpreter.on('blame_line') do |e|
        blame(content.current_line.commit.sha)
      end

      command_interpreter.on('blame_prev') do |e|
        # Split the sha and file name into separate args
        prev = content.current_line.commit.previous
        if prev
          blame(*prev.split(' '))
        else
          command_line.model.message = "Error: No previous commit"
        end
      end

      command_interpreter.on('show') do |e, cmd|
        Curses.endwin
        clear_cmd
        cmd = "git show #{content.current_line.commit.sha} -- #{model.file}"
        puts cmd
        system(cmd)
        $stdout.print "Back to blame (Y/n)? "
        response = $stdin.gets.strip
        if response.start_with?('n') || response.start_with?('N')
          exit
        end
        Curses.initscr
      end

      command_interpreter.on('pagedown') do
        content.go_page_down
        command_line.model.message = ""
      end

      command_interpreter.on('pageup') do
        content.go_page_up
        command_line.model.message = ""
      end

      command_interpreter.on('pagestart') do
        content.goto_first_line
        command_line.model.message = ""
      end

      command_interpreter.on('pageend') do
        content.goto_last_line
        command_line.model.message = ""
      end

      command_interpreter.on('goto') do |e, line|
        content.goto_line(line)
        command_line.model.message = ""
      end

      command_interpreter.on('error') do |e, error|
        command_line.model.message = "Error: #{error}"
      end
    end

    def blame(ref, file=nil)
      if 'commit' != Git.obj_type(ref) &&
        command_line.model.message = "Error: Not a commit - #{ref}"
      elsif 'blob' != Git.obj_type(ref + ':' + (file || model.file))
        command_line.model.message = "Error: Not an object - #{ref}:#{file}"
      else
        command_line.model.message = "Loading..."
        CUI.once('render:end') do
          model.file = file || model.file
          model.blame.load(model.file, ref)
          model.revision = ref
          command_line.model.message = "Done."
          set_details
        end
      end
    end

    def previous_revision
      if 'commit' == Git.obj_type("#{content.current_line.commit.sha}^")
        Git.rev_parse("#{content.current_line.commit.sha}^")
      else
        nil
      end
    end

    def clear_cmd
      if ENV['OS'] && ENV['OS'].downcase.start_with?('win')
        system('cls')
      else
        system('clear')
      end
    end
  end
end
