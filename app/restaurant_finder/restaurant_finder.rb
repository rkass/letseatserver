class RestaurantFinder

  attr_accessor :invitation, :restaurants, :restaurants_mutex
  def initialize(invitation, restaurants)
    @invitation = invitation
    @restaurants = restaurants
    @restaurants_mutex = Mutex.new
  end 

  def self.getAssociatedCategories(category)
    if category.downcase == "american"
      return "newamerican,tradamerican,bbq,burgers,cheesesteaks,chicken_wings,comfortfood,sandwiches,soulfood,southern"
    elsif category.downcase == "cafe"
      return "bubbletea,coffee,cafes"
    elsif category.downcase == "chinese"
      return "chinese"
    elsif category.downcase == "dessert"
      return "bakeries,cupcakes,desserts,donuts,gelato,icecream,juicebars,shavedice"
    elsif category.downcase == "diner"
      return "diners"
    elsif category.downcase == "indian"
      return "indpak"
    elsif category.downcase == "italian"
      return "italian,pizza"
    elsif category.downcase == "japanese"
      return "japanese,sushi"
    elsif category.downcase == "korean"
      return "korean"
    elsif category.downcase == "mediterranean"  
      return "mediterranean,greek,mideastern"
    elsif category.downcase == "mexican"
      return "mexican,tex-mex,latin"
    elsif category.downcase == "seafood"
      return "seafood"
    elsif category.downcase == "spanish"
      return "spanish,tapasmallplates"
    elsif category.downcase == "steakhouse"
      return "steak"
    elsif category.downcase == "thai"
      return "thai"
    elsif category.downcase == "vegetarian"
      return "vegetarian,vegan"
    elsif category.downcase == "vietnamese"
      return "vietnamese"
  end

  def find(categories, parallel = true)
    if parallel
      Parallel.each(categories) do |category|
        #ActiveRecord::Base.connection.reconnect!
        searchCategory(0, category, 2000)
      end
    else
      categories.each do |category|
        searchCategory(0, category, 2000, false)
      end
    end
  end

  def exists(yelpResult)
    @restaurants_mutex.synchronize{
      for r in @restaurants
        return true if r.url == yelpResult['mobile_url']
      end
    }
    return false
  end

  def searchCategory(viableOptions, category, radius, parallel = true)
    category = RestaurantFinder.getAssociatedCategories
    viableOptions = viableOptions
    categoryMutex = Mutex.new
    yelpResults = Yelp.getResults(invitation.location, category, radius)
    if parallel
      Parallel.each(yelpResults) do |yelpResult|
   #     ActiveRecord::Base.connection.reconnect!
        if (not exists(yelpResult))
          isOpenAndPrice = GooglePlaces.isOpenAndPrice(RestaurantFinder.getFormattedAddressFromYelpResult(yelpResult), invitation.dayOfWeek, invitation.timeOfDay)       
          restaurant = []#Restaurant.new({:name => yelpResult['name'], :price => isOpenAndPrice.price, :address => yelpResult['location']['display_address'] * ",", :url => yelpResult['mobile_url'], :rating_img => yelpResult['rating_img_url'], :snippet_img => yelpResult['image_url'], :rating => yelpResult['rating'], :categories => yelpResult['categories'], :review_count => yelpResult['review_count'], :open_start => isOpenAndPrice.openStart, :open_end => isOpenAndPrice.openEnd, :open => isOpenAndPrice.open, :distance => yelpResult['distance']})
          @restaurants_mutex.synchronize{
            @restaurants.append(restaurant)
          }
          categoryMutex.synchronize{viableOptions += 1} if restaurant.open
        end 
      end
    else
      yelpResults.each do |yelpResult|
        if (not @invitation.restaurants.where(url:yelpResult['mobile_url']).exists?)
          isOpenAndPrice = GooglePlaces.isOpenAndPrice(getFormattedAddressFromYelpResult(yelpResult), @invitation.dayOfWeek, @invitation.timeOfDay)
          restaurant = @invitation.restaurants.create({:name => yelpResult['name'], :price => isOpenAndPrice.price, :address => yelpResult['location']['display_address'] * ",", :url => yelpResult['mobile_url'], :rating_img => yelpResult['rating_img_url'], :snippet_img => yelpResult['image_url'], :rating => yelpResult['rating'], :categories => yelpResult['categories'], :review_count => yelpResult['review_count'], :open_start => isOpenAndPrice.open_start, :open_end => isOpenAndPrice.open_end, :open => isOpenAndPrice.open, :distance => yelpResult['distance']})
          categoryMutex.synchronize{viableOptions += 1} if restaurant.open 
        end
      end
    end
    searchCategory(viableOptions, category, location, [40000, (radius * 2)].min) if ((viableOptions < 5) and (radius < 40000))
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
