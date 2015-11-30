#! /usr/bin/env cui

def __main__(argv)
  $DEBUG = false

  puts argv.join(',')

  if argv[0] != 'blame'
    $stderr.puts "Usage: git-curses blame [<rev>] <file>"
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
    exit 1
  end

  unless 'commit' == Git.obj_type(rev)
    $stderr.puts "No such commit: #{rev}"
    exit 1
  end

  unless 'blob' == Git.obj_type("#{rev}:#{file}")
    $stderr.puts "No such object: #{rev}:#{file}"
    exit 1
  end

  CUI.init
  GitCurses::Colors.init
  GitCurses.run(file, rev)
end
