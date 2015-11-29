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

$log = File.open('log.txt', 'w')

w1 = CUI::Window.new({
  lines: 4,
  cols: 11,
  begy: 2,
  begx:2
})
def w1.render
  io.goto(1, 1);
  io.write_line_right('Window #1')
  io.box()
end

w2 = CUI::Window.new({
  lines: 4,
  cols: 11,
  begy: 8,
  begx:2
})
def w2.render
  io.goto(1, 1);
  io.write_line_right('Window #2')
  io.box()
end

CUI::EventLoop.windows.push(w1)
CUI::EventLoop.windows.push(w2)
w1.focus
CUI::EventLoop.on(CUI::KeyEvent) do |k|
  if k.keyname == '^C'
    CUI::EventLoop.exit
  elsif k.keyname == 'KEY_RESIZE'
    w1.resize(w1.height * 2, w1.width * 2)
    w1.io.goto(w1.begy, w1.begx);
    w1.render
    w1.render

    w2.resize(w2.height * 2, w2.width * 2)
    w2.mv(5, 5)
    w2.render

    Curses.update_panels
    Curses.doupdate
  end
end
CUI::EventLoop.run
