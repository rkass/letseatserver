class Preferences
  attr_accessor :location, :ratings_dict, :minPrice, :maxPrice
  def initialize(ratings_dict, location, minPrice, maxPrice)
    @ratings_dict = ratings_dict
    @location = location
    @minPrice = minPrice
    @maxPrice = maxPrice
    normalizeRatingsDict
  end

  def getCategoriesRated(rating)
    ret = []
    for k in @ratings_dict.keys
      ret.append(k) if @ratings_dict[k] == rating
    end
    ret.collect{|c| c}.join(",")
  end

  def normalizeRatingsDict
    return if @ratings_dict == nil or @ratings_dict["indpak"] != nil
    rd = {}
    for k in @ratings_dict.keys
      rd[RestaurantFinder.categoriesDict[k]] = @ratings_dict[k] if RestaurantFinder.categoriesDict.include?k
    end
    @ratings_dict = rd
  end
end
