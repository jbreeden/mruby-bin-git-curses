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

  def obj_type(ref)
    type = nil
    IO.popen("git cat-file -t #{ref} 2> /dev/null", 'r') do |io|
      maybe_type = io.gets
      Process.wait(io.pid)
      if $?.exitstatus == 0
        type = maybe_type.strip
      end
    end
    type
  end

end
end

module GitDig
  Git = ::Git
end
