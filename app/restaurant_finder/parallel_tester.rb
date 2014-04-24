class ParallelTester

  attr_accessor :zip
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
    Parallel.each([3, 4, 5]) do
      puts "Zip is #{@zip}"
    end
  end

end
