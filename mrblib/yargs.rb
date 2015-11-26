class Yargs
  def initialize(argv, mode = nil)
    @argv = argv
    @consume = (mode == :consume)
  end

  def flag(*names)
    name_regex = "(#{names.join('|')})"
    index = @argv.find_index { |e| e =~ /^(-){1,2}#{name_regex}$/ }
    if index != nil
      @argv.delete_at(index) if @consume
      return true
    end
    return false
  end

  def value(*names)
    name_regex = "(#{names.join('|')})"
    index = @argv.find_index { |e| e =~ /^(-){1,2}#{name_regex}(=.*)?$/ }
    if index != nil
      equals_index = @argv[index].index('=')
      if equals_index
        val = @argv[index][(equals_index + 1)..(@argv[index].length)]
        @argv.delete_at(index) if @consume
        return val
      else
        if (index + 1) < @argv.length && !(@argv[index + 1] =~ /^-{1,2}/)
          val =  @argv[index + 1]
          @argv.delete_at(index + 1) if @consume
          @argv.delete_at(index) if @consume
          return val
        end
      end
    end
    return nil
  end
end
