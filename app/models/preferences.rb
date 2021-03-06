class Preferences
  attr_accessor :location, :ratings_dict, :minPrice, :maxPrice, :top5
  def initialize(ratings_dict, location, minPrice, maxPrice, top5)
    @ratings_dict = ratings_dict
    @location = location
    @minPrice = minPrice
    @maxPrice = maxPrice
    @top5 = top5
    normalizeRatingsDict
  end

  def getCategoriesRated(rating)
    ret = []
    for k in @ratings_dict.keys
      ret.append(k) if @ratings_dict[k] == rating
    end
    ret.collect{|c| c}.join(",")
  end
  
  def ones
    getCategoriesRated(1)
  end
  
  def twos
    getCategoriesRated(2)
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
