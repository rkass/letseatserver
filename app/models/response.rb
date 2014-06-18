class Response < Preferences
 attr_accessor :going, :message
 def initialize(going, message, ratings_dict, location, minPrice, maxPrice, top5)
    @going = going
    @message = message
    @ratings_dict = ratings_dict
    @location = location
    @minPrice = minPrice
    @maxPrice = maxPrice
    @top5 = top5
    normalizeRatingsDict
  end
end
