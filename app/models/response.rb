class Response < Preferences
 attr_accessor :going, :message
 def initialize(going, message, types_list, location, minPrice, maxPrice)
    @going = going
    @message = message
    @types_list = types_list
    @location = location
    @minPrice = minPrice
    @maxPrice = maxPrice
  end
=begin
  def going
    @going
  end
  def message
    @message
  end
=end
end
