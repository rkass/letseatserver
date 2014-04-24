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
    100.times{
      Thread.new{
        foo
      }
    }
    puts "Zip is #{@zip}"
  end

end
