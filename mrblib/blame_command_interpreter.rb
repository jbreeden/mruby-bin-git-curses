module GitCurses
class BlameCommandInterpreter
  include CUI::Events

  def initialize(blame)
    super()
    @blame = blame
  end

  def interpret(str)
    self.instance_eval(str)
  rescue Exception => ex
    trigger('error', ex)
  end

  def blame(commit, file=nil)
    if sha = Git.rev_parse(commit, file)
      trigger('blame', sha, file)
    else
      trigger('error', "No such commit #{commit} #{'for file ' + file if file}")
    end
  end

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
    trigger('goto', line_num)
  end

  def eval(&block)
    trigger('eval', block)
  end
end
end
