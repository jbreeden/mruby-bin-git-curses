$DEBUG = false

load 'mrblib/yargs.rb'

# Framework
$: << 'cui'
load 'cui.rb'

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
