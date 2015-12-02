#! /usr/bin/env cui

def usage(f=$stderr)
  f.puts "Usage: git-curses blame [<rev>] <file>"
end

def __main__(argv)
  # Only command supported so far
  case argv[0]
  when 'blame'
    GitCurses.mode_blame(argv)
  else
    usage
    exit 1
  end
end
