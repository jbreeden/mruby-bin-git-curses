MRuby::Gem::Specification.new('mruby-bin-git-curses') do |spec|
  spec.author = 'Jared Breeden'
  spec.summary = 'Curses UI for git'
  spec.license = 'MIT'
  spec.add_dependency 'mruby-apr'
  spec.add_dependency 'mruby-curses'
  spec.bins = ['git-curses']

  gem_dir = File.expand_path(File.dirname(__FILE__))

  spec.rbfiles.clear
  spec.rbfiles.push "#{gem_dir}/mrblib/colors.rb"
  spec.rbfiles.push "#{gem_dir}/mrblib/blame.rb"
  spec.rbfiles.push "#{gem_dir}/mrblib/mode-blame.rb"
  spec.rbfiles.push "#{gem_dir}/mrblib/content.rb"
  spec.rbfiles.push "#{gem_dir}/mrblib/blame_details.rb"
  spec.rbfiles.push "#{gem_dir}/mrblib/command_line.rb"
  spec.rbfiles.push "#{gem_dir}/mrblib/blame_command_interpreter.rb"
  spec.rbfiles.push "#{gem_dir}/mrblib/git.rb"
  spec.rbfiles.push "#{gem_dir}/mrblib/yargs.rb"
  spec.rbfiles.push "#{gem_dir}/mrblib/main.rb"
end
