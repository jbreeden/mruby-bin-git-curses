load 'mrblib/yargs.rb'

# Framework
load 'cui/events.rb'
load 'cui/builtin_events.rb'
load 'cui/event_loop.rb'
load 'cui/window.rb'
load 'cui/window_io.rb'

# App Specific
load 'mrblib/colors.rb'
load 'mrblib/blame.rb'
load 'mrblib/mode-blame.rb'
load 'mrblib/content.rb'
load 'mrblib/header.rb'
load 'mrblib/status_bar.rb'
load 'mrblib/command_line.rb'

$log = File.open('log.txt', 'w')

Dir.chdir '../mruby-curses' do
  GitDig.run('src/mruby_Curses.c')
end
