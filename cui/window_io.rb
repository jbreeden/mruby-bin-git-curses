module CUI
module WindowIO
  def each_line(&block)
    if block_given?
      # Up to but not including...
      (0...self.maxy).each do |line_num|
        block[line_num]
      end
    else
      self.enum_for(:each_line)
    end
  end

  def readline
    self.on(CUI::Events::All) do |e|
      
    end
  end
end
end
