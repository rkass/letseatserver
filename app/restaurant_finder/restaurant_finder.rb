class RestaurantFinder

  @@translation_dict = {"american" => "newamerican,tradamerican,bbq,burgers,cheesesteaks,chicken_wings,comfortfood,sandwiches,soulfood,southern",
                        "cafe" => "bubbletea,coffee,cafes",
                        "chinese" => "chinese",
                        "dessert" => "bakeries,cupcakes,desserts,donuts,gelato,icecream,juicebars,shavedice",
                        "diner" => "diners",
                        "indian" => "indpak",
                        "italian" => "italian,pizza",
                        "japanese" => "japanese,sushi",
                        "korean" => "korean",
                        "mediterranean" => "mediterranean,greek,mideastern",
                        "mexican" => "mexican,tex-mex,latin",
                        "seafood" => "seafood", 
                        "spanish" => "spanish,tapasmallplates",
                        "steakhouse" => "steak",
                        "thai" => "thai",
                        "vegetarian" => "vegetarian,vegan",
                        "vietnamese" => "vietnamese"
  }
  
  #restaurants is a dictionary representing restaurants
  attr_accessor :invitation, :restaurants, :restaurants_mutex, :x
  def initialize(invitation)
    @invitation = invitation
    @restaurants_mutex = Mutex.new
  end 

  def self.translationDict
    @@translation_dict
  end

  def self.getAssociatedCategories(category)
    translationDict[category.downcase] 
  end

  def self.getLECategory(yelpCategory)
    translationDict.each{ |k, v| return k if (v.include?yelpCategory)}
    return nil
  end

  def find(categories, parallel = true)
    loc = @invitation.location
    dow = @invitation.dayOfWeek
    tod = @invitation.timeOfDay
    if parallel
      categories.each do |category|
        #ActiveRecord::Base.connection.reconnect!
        self.searchCategory(0, category, 2000, loc, dow, tod)
      end
    else
      categories.each do |category|
        searchCategory(0, category, 2000, loc, dow, tod,false)
      end
    end
  end

  def exists(yelpResult)
    @restaurants_mutex.synchronize{
      for r in @restaurants
        return true if r[:url] == yelpResult['mobile_url']
      end
    }
    return false
  end

  def fillGaps
    avg_open_start = 0
    avg_open_end = 0
    start_count = 0
    end_count = 0
    for r in @invitation.restaurants
      if r.open_start != nil
        avg_open_start += r.open_start.to_i
        start_count += 1  
      end
      if r.open_end != nil
        avg_open_end += r.open_end.to_i
        end_count += 1
      end
    end
    avg_open_start = avg_open_start / start_count
    avg_open_end = avg_open_end / end_count
    for r in @invitation.restaurants
      r.open_start = avg_open_start if r.open_start == nil
      r.open_end = avg_open_end if r.open_end == nil
      r.open = (@invitation.time.to_i >= r.open_start and @invitation.time.to_i <= r.open_end) if r.open == nil
      r.save
    end
  end

  def searchCategory(viableOptions, category, radius, location, dow, tod,parallel = true)
    assoc_categories = RestaurantFinder.getAssociatedCategories(category)
    viableOptions = viableOptions
    yelpResults = Yelp.getResults(location, assoc_categories, radius)
    if parallel
      ActiveRecord::Base.connection.disconnect!
      results = Parallel.map(yelpResults) do |yelpResult|
        if (not @invitation.restaurants.where(url:yelpResult['mobile_url']).exists?)
          isOpenAndPrice = GooglePlaces.isOpenAndPrice(RestaurantFinder.getFormattedAddressFromYelpResult(yelpResult), dow, tod)
          os = OpenStruct.new
          os.restaurant = {:name => yelpResult['name'], :price => isOpenAndPrice.price, :address => yelpResult['location']['display_address'] * ",", :url => yelpResult['mobile_url'], :rating_img => yelpResult['rating_img_url'], :snippet_img => yelpResult['image_url'], :rating => yelpResult['rating'], :categories => yelpResult['categories'], :review_count => yelpResult['review_count'], :open_start => isOpenAndPrice.openStart, :open_end => isOpenAndPrice.openEnd, :open => isOpenAndPrice.open, :distance => yelpResult['distance']}
          os.requests = isOpenAndPrice.requests 
          os
        end
      end
    ActiveRecord::Base.establish_connection
    results.each do |os|
      if os != nil
        @invitation.restaurants.create(os.restaurant)
        os.requests.each{ |req| Request.create(req) }
        viableOptions += 1 if os.restaurant[:open]
      end
    end 
    else
      yelpResults.each do |yelpResult|
        if (not @invitation.restaurants.where(url:yelpResult['mobile_url']).exists?)
          isOpenAndPrice = GooglePlaces.isOpenAndPrice(RestaurantFinder.getFormattedAddressFromYelpResult(yelpResult), dow,tod)
          restaurant = @invitation.restaurants.create({:name => yelpResult['name'], :price => isOpenAndPrice.price, :address => yelpResult['location']['display_address'] * ",", :url => yelpResult['mobile_url'], :rating_img => yelpResult['rating_img_url'], :snippet_img => yelpResult['image_url'], :rating => yelpResult['rating'], :categories => yelpResult['categories'], :review_count => yelpResult['review_count'], :open_start => isOpenAndPrice.open_start, :open_end => isOpenAndPrice.open_end, :open => isOpenAndPrice.open, :distance => yelpResult['distance']})
          viableOptions += 1 if restaurant.open 
        end
      end
    end
    searchCategory(viableOptions, category,  [40000, (radius * 2)].min, location, dow, tod, parallel) if ((viableOptions < 5) and (radius < 40000))
  end

  def self.nilEscape(str)
    if str == nil
      return "" 
    end
    return str
  end

  def self.getFormattedAddressFromYelpResult(yelpDict)
    nilEscape(yelpDict['name']) + ", " + nilEscape(yelpDict['location']['address'][0]) + ", " + nilEscape(yelpDict['location']['city']) + ", " + nilEscape(yelpDict['location']['state_code']) + " " + nilEscape(yelpDict['location']['postal_code']) + ", " + nilEscape(yelpDict['location']['country_code'])
  end

=begin
  def yelpToRestaurant(yelpDict, dow, time)
    isOpenAndPrice = GooglePlaces.isOpenAndPrice(getYelpFormattedAddress(yelpDict), dow, time)
    Restaurant.new(yelpDict['name'], isOpenAndPrice.price, yelpDict['location']['display_address'] * ",", yelpCategoriesToLECategories(yelpDict['categories']), yelpDict['mobile_url'], yelpDict['rating_img_url'], yelpDict['image_url'], yelpDict['rating'], yelpDict['categories'], yelpDict['review_count'])
  end
=end

end
