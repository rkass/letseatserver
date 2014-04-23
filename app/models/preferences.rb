class Preferences
  attr_accessor :location, :types_list, :minPrice, :maxPrice
  def initialize(types_list, location, minPrice, maxPrice)
    @types_list = types_list
    @location = location
    @minPrice = minPrice
    @maxPrice = maxPrice
  end
=begin
  def types_list
    @types_list
  end
  def location
    @location
  end
  def minPrice
    @minPrice
  end
  def maxPrice
    @maxPrice
  end
=end
end
