#! /usr/bin/env cui

def self.usage(f=$stderr)
  f.puts <<-EOS
Usage: git curses COMMAND [OPTIONS...]

COMMANDs
  blame - Perform an interactive git blame
EOS
end

def __main__(argv)
  # Only command supported so far
  case argv[0]
  when 'blame'
    GitCurses::BlameMode.run(argv)
  else
    usage
    exit 1
  end
  
  CUI.on(CUI::KeyEvent) do |e|
    if ['^Q', '^C'].include?(e.keyname)
      CUI.exit!(0)
    end
  end

  # Use Nurb event loop, if available
  if Object.const_defined?(:Nurb)
    Nurb.set_interval(30) do
      CUI.run_once
    end
    Nurb.run
  else
    CUI.run
  end
end
