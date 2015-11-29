module GitCurses
module Git
class << self
  def rev_parse(rev, file=nil)
    parsed = nil
    IO.popen("git rev-parse #{rev}#{(':' + file) if file} 2> /dev/null", 'r') do |io|
      maybe_rev = io.gets
      Process.wait(io.pid)
      if $?.exitstatus == 0
        parsed = maybe_rev.strip
      end
    end
    parsed
  end
end
end
end
