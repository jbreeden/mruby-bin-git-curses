module GitCurses
  class Blame
    include CUI::Events

    attr_accessor :lines, :commits

    def initialize
      super
      # Indexed by line number
      @lines = []
      # hashes by the sha string
      @commits = {}
    end

    def clear
      @lines = []
      @commits = {}
      trigger('clear')
    end

    def load(file, rev='HEAD', &block)
      clear
      IO.popen("git blame --porcelain #{rev} #{file}", 'r') do |io|
        current_commit = nil
        until io.eof?
          # Parse the first line
          tokens = io.gets.split(' ')
          raise "Line doesn't look like a chunk header: #{tokens.join(' ')}" unless tokens.length == 4

          # Grab the chunk title line info
          sha = tokens[0]
          line_prev = tokens[1].to_i
          line_cur = tokens[2].to_i
          number_of_lines = tokens[3].to_i

          # Parse the commit
          c = nil
          current_commit = nil
          if self.seen?(sha)
            # Advance past header, we've seen this commit
            current_commit = @commits[sha]
            c = io.getc until c == "\t"
          else
            headers = ''
            until (c = io.getc) == "\t"
              headers << c
            end
            current_commit = Commit.new(sha)
            block[current_commit] if block_given?
            current_commit.parse_str(headers)
            @commits[sha] = current_commit
          end

          # We're now to the first line, excluding the leading tab character
          content = io.gets
          blame_line = BlameLine.new(current_commit, line_prev, line_cur, content)
          block[blame_line] if block_given?
          @lines.push(blame_line)

          # Parse the remaining lines in this chunk
          (number_of_lines - 1).times do
            line = io.gets
            raise "Line doesn't look like a content line header: #{line}" unless line =~ /^(\S+\s*){3}$/
            tokens = line.split(' ')
            line_prev = tokens[1].to_i
            line_cur = tokens[2].to_i
            io.getc # Remove tab
            content = io.gets
            blame_line = BlameLine.new(current_commit, line_prev, line_cur, content)
            lines.push(blame_line)
            block[blame_line] if block_given?
          end
        end
      end
      trigger('load')
    end

    def seen?(sha)
      !(@commits[sha].nil?)
    end
  end

  commit_attrs = [:sha, :author, :author_mail, :author_time, :summary]
  class Commit
    attr_reader :sha, :author, :author_mail, :author_time, :summary, :previous
    def initialize(sha = nil, author = nil, author_mail = nil, author_time = nil, summary = nil)
      @sha = sha; @author = author; @author_mail = author_mail; @author_time = author_time; @summary = summary;
    end

    def parse_str(str)
      str.each_line do |line|
        tokens = line.split(' ')
        reader = "#{tokens[0].gsub('-', '_')}"
        iv = "@#{reader}".to_sym
        if self.respond_to?(reader) && tokens.length > 1
          self.instance_variable_set(iv, tokens[1..(tokens.length)].join(' '))
        end
      end

      @author_time = Time.at(@author_time.to_i) if @author_time
    end
  end

  class BlameLine
    attr_reader :commit,
      :line_prev,
      :line_cur,
      :content

    def initialize(commit, line_prev, line_cur, content)
      @commit = commit
      @line_prev = line_prev
      @line_cur = line_cur
      @content = content
    end
  end
end
