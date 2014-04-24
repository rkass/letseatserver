class ParallelTester

  def initialize
    @mutex = Mutex.new
    @zip = 42
  end
    
  def foo
    @mutex.synchronize do
      @zip += 1
    end
  end
  
  def incrementHundred
    ([0] * 100).each do
      Thread.new{
        foo
      }
    end
    puts "Zip is #{@zip}"
  end

end
