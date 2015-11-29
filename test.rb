load 'mrblib/yargs.rb'

# Framework
$: << 'cui'
load 'cui.rb'

$log = File.open('log.txt', 'w')

w1 = CUI::Window.new(lines: 10, cols: 10)
class << w1
  def render
    clear
    io.goto(1, 1);
    io.write_line_right('Window #1')
    io.box()
  end
end

w2 = CUI::Window.new(lines: 10, cols: 10)
class << w2
  def render
    io.goto(1, 1);
    io.write_line_right('Window #2')
    io.box()
  end
end
w2.focus

CUI.screen.add_children(w1, w2)

class << CUI.screen
  def layout
    dim = [(CUI.screen.maxy / 2).to_i, (CUI.screen.maxx / 2).to_i]
    @children[0].mv(2, 2)
    @children[0].resize(*dim)
    @children[1].mv(4, 4)
    @children[1].resize(*dim)
  end
end

CUI::EventLoop.on(CUI::KeyEvent) do |k|
  if k.keyname == '^C'
    CUI::EventLoop.exit
  end
end
CUI::EventLoop.run
