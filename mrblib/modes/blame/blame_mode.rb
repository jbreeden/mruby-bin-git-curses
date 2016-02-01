$DEBUG = false

module GitCurses
  module BlameMode
    def self.usage(f=$stderr, msg=nil)
      if msg
          f.puts msg
      end
      
      f.puts <<-EOS
Usage: git-curses blame [<rev>] <file>

Commands
  Commands entered in the command line are treated like shell commands.
  (No need to quote strings, unless they have spaces, etc.)
  Ex: `blame HEAD^` would blame the parent commit of HEAD.
  
  blame sha [, file] 
    Blame the given sha from the current file, or the `file` arg.
    (aliases: b)
  
  blame_prev
    Blame the commit prior to the one that last changed the current line.
    (aliases: bp)
  
  blame_line
    Blame the commit that last changed the current line.
    (aliases: bl)
  
  blame_head
    Blame the HEAD revision of the current file.
    (aliases: bh)
  
  pagedown
    Move one page down.
    (aliases: pd)
  
  pageup
    Move one page up.
    (aliases: pu)
  
  pagestart
    Go to page start.
    (aliases: ps, top, first)
  
  pageend
    Go to page end.
    (aliases: pe, bottom, last)
    
  goto line
    Go to the given line number.
    
  show
    Shows the commit that last changed the current line.
    This is performed by suspending the current blame and executing
    the `git show ...` command in the shell.
  
  help
    Show this help text
    
  quit
    Exit the application. Could also send ctrl-C.
    (aliases: q, exit)
EOS
    end
    
    def self.run(argv)
      if !(argv[1].nil?) && (argv[1] == 'help' || argv[1] == '-h' || argv[1] == '--help')
        usage
        exit 0
      end
      
      if argv.length < 2
        usage($stderr, 'Too few arguments.')
        exit 1
      end
      
      if argv.length > 3
        usage($stderr, 'Too many arguments.')
        exit 1
      end

      if argv.length == 2
        rev = 'HEAD'
        file = argv[1]
      elsif argv.length == 3
        rev = argv[1]
        file = argv[2]
      end

      unless File.exists?(file)
        $stderr.puts "No such file: #{file}"
        usage
        exit 1
      end

      unless 'commit' == Git.obj_type(rev)
        if rev =~ /head/i
          $stderr.puts "Not a git repo"
          usage
        else
          $stderr.puts "No such commit: #{rev}"
          usage
        end
        exit 1
      end

      unless 'blob' == Git.obj_type("#{rev}:#{file}")
        $stderr.puts "No such object: #{rev}:#{file}"
        usage
        exit 1
      end

      CUI.init
      GitCurses::Colors.init
      blame_view = BlameView.new({file: file, revision: rev})
      CUI.screen.add_child(blame_view)
    end
  end
end
