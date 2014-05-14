class Response < Preferences
 attr_accessor :going, :message
 def initialize(going, message, ratings_dict, location, minPrice, maxPrice)
    @going = going
    @message = message
    @ratings_dict = ratings_dict
    @location = location
    @minPrice = minPrice
    @maxPrice = maxPrice
    normalizeRatingsDict
  end
end
