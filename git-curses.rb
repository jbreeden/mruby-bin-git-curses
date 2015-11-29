$DEBUG = false

load 'mrblib/yargs.rb'

# Framework
load 'cui/events.rb'
load 'cui/model.rb'
load 'cui/builtin_events.rb'
load 'cui/event_loop.rb'
load 'cui/window_delegates.rb'
load 'cui/window.rb'
load 'cui/window_io.rb'
load 'cui/text_input.rb'

# App Specific
load 'mrblib/colors.rb'
load 'mrblib/blame.rb'
load 'mrblib/mode-blame.rb'
load 'mrblib/content.rb'
load 'mrblib/blame_details.rb'
load 'mrblib/command_line.rb'
load 'mrblib/blame_command_interpreter.rb'
load 'mrblib/git.rb'

$log = File.open('log.txt', 'w')

Dir.chdir '../mruby' do
  GitCurses.run('include/mruby.h')
end
