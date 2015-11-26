module CUI
  class KeyEvent
    attr_accessor :key, :keyname

    def initialize(ch)
      self.key = ch
      self.keyname = Curses.keyname(ch)
    end

    def to_i
      self.key
    end

    def to_s
      self.keyname.to_s
    end
  end
end
