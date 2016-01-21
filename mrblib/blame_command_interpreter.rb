module GitCurses
class BlameCommandInterpreter
  include CUI::Events

  def initialize()
    super()
  end

  def interpret(str)
    tokens = Shellwords.split(str)
    self.send(tokens[0], *tokens[1..(tokens.length)]) if tokens.length > 0
  rescue Exception => ex
    trigger('error', ex)
  end

  def blame(ref, file = nil)
    trigger('blame', ref, file)
  end
  alias b blame

  def blame_prev
    trigger('blame_prev')
  end
  alias bp blame_prev

  def blame_line
    trigger('blame_line')
  end
  alias bl blame_line

  def blame_head
    trigger('blame_head')
  end
  alias bh blame_head

  def pagedown
    trigger('pagedown')
  end
  alias pd pagedown

  def pageup
    trigger('pageup') # Always causes a segfault
  end
  alias pu pageup

  def pagestart
    trigger('pagestart')
  end
  alias ps pagestart
  alias top pagestart
  alias first pagestart

  def pageend
    trigger('pageend')
  end
  alias pe pageend
  alias bottom pageend
  alias last pageend

  def goto(line_num)
    if /[0-9]+/ =~ line_num
      trigger('goto', line_num.to_i)
    else
      trigger('error', "Not a number - #{line_num}")
    end
  end

  def show
    trigger('show')
  end
  
  def help
    trigger('help')
  end
  
  def exit
    Curses.endwin
    Kernel.exit(0)
  end
  alias quit exit
  alias q exit

  def method_missing(name, *args, &block)
    raise "No such command: #{name}"
  end
end
end
