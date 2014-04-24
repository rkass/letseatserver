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
    Parallel.each([0] * 100) do
      foo
    end
    puts "Zip is #{@zip}"
  end

end
