MRuby::Gem::Specification.new('mruby-bin-git-curses') do |spec|
  spec.author = 'Jared Breeden'
  spec.summary = 'Curses UI for git'
  spec.license = 'MIT'
  spec.add_dependency 'mruby-apr'
  spec.add_dependency 'mruby-curses'
  spec.bins = ['git-curses']

  gem_dir = File.expand_path(File.dirname(__FILE__))

  spec.rbfiles.clear
  spec.rbfiles.push "#{gem_dir}/mrblib/yargs.rb"
  spec.rbfiles.push "#{gem_dir}/mrblib/colors.rb"
  spec.rbfiles.push "#{gem_dir}/mrblib/git.rb"
  
  # Models
  spec.rbfiles.push "#{gem_dir}/mrblib/models/blame.rb"
  
  # Views
  spec.rbfiles.push "#{gem_dir}/mrblib/views/command_line.rb"
  spec.rbfiles.push "#{gem_dir}/mrblib/views/blame.rb"
  spec.rbfiles.push "#{gem_dir}/mrblib/views/blame_details.rb"
  spec.rbfiles.push "#{gem_dir}/mrblib/views/blame_content.rb"
  
  # Modes
  spec.rbfiles.push "#{gem_dir}/mrblib/modes/blame/blame_mode.rb"
  spec.rbfiles.push "#{gem_dir}/mrblib/modes/blame/blame_command_interpreter.rb"
  
  spec.rbfiles.push "#{gem_dir}/mrblib/main.rb"
end
