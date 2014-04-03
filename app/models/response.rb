class Response < Preferences
  def initialize(going, message, types_list, location, minPrice, maxPrice)
    @going = going
    @message = message
    @types_list = types_list
    @location = location
    @minPrice = minPrice
    @maxPrice = maxPrice
  end
  def going
    @going
  end
  def message
    @message
  end
end
