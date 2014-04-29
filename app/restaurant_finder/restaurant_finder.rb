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
                        "vietnamese" => "vietnamese",
                        "restaurants" => "restaurants"
  }
  
  #restaurants is a dictionary representing restaurants
  attr_accessor :invitation, :client
  def initialize(invitation)
    @invitation = invitation
    @client = Places::Client.new
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
    self.searchCategory(0, "restaurants", 2000, loc, dow, tod) if (@invitation.restaurants.select{|r| r.open}.length < 15)
  end

  def fillGaps
    starts = []
    ends = []
    avg_price = 0.0
    price_count = 0.0
    for r in @invitation.restaurants
      if r.open_start != nil
        starts.append(r.open_start)
      end
      if r.open_end != nil
        ends.append(r.open_end)
      end
      if r.price != nil
        avg_price += 1
        price_count += 1
      end
    end
    if starts == []
      avg_open_start = "1400"
    else
      avg_open_start = starts.max_by { |v| starts.inject(Hash.new(0)) { |h,v| h[v] += 1; h }[v] }
    end
    if ends == []
      avg_open_end = "2000"
    else
      avg_open_end = ends.max_by { |v| ends.inject(Hash.new(0)) { |h,v| h[v] += 1; h }[v] }
    end
    if price_count == 0
      avg_price = 2
    else
      avg_price = avg_price / price_count.round(0)
    end
    for r in @invitation.restaurants
      r.open_start = avg_open_start if r.open_start == nil
      r.open_end = avg_open_end if r.open_end == nil
      r.open = (@invitation.time.to_i >= r.open_start.to_i and @invitation.time.to_i <= r.open_end.to_i) if r.open == nil
      r.price = avg_price if r.price == nil
      r.save
    end
  end

  def searchCategory(viableOptions, category, radius, location, dow, tod,parallel = true)
    assoc_categories = RestaurantFinder.getAssociatedCategories(category)
    viableOptions = viableOptions
    yelpResults = Yelp.getResults(location, assoc_categories, radius)
    lat = @invitation.location.split(',')[0].to_f
    lng = @invitation.location.split(',')[1].to_f
    if parallel
      ActiveRecord::Base.connection.disconnect!
      results = Parallel.map(yelpResults) do |yelpResult|
        if (not @invitation.restaurants.where(url:yelpResult['mobile_url']).exists?)
          puts "isopeningandprice"
          isOpenAndPrice = MyGooglePlaces.isOpenAndPrice(RestaurantFinder.getFormattedAddressFromYelpResult(yelpResult), dow, tod, @client, lat, lng, yelpResult['name'])
          os = OpenStruct.new
          os.restaurant = {:name => yelpResult['name'], :price => isOpenAndPrice.price, :address => yelpResult['location']['display_address'] * ",", :url => yelpResult['mobile_url'], :rating_img => yelpResult['rating_img_url'], :snippet_img => yelpResult['image_url'], :rating => yelpResult['rating'], :categories => yelpResult['categories'], :review_count => yelpResult['review_count'], :open_start => isOpenAndPrice.open_start, :open_end => isOpenAndPrice.open_end, :open => isOpenAndPrice.open, :distance => yelpResult['distance']}
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
          isOpenAndPrice = MyGooglePlaces.isOpenAndPrice(RestaurantFinder.getFormattedAddressFromYelpResult(yelpResult), dow,tod, @client)
          restaurant = @invitation.restaurants.create({:name => yelpResult['name'], :price => isOpenAndPrice.price, :address => yelpResult['location']['display_address'] * ",", :url => yelpResult['mobile_url'], :rating_img => yelpResult['rating_img_url'], :snippet_img => yelpResult['image_url'], :rating => yelpResult['rating'], :categories => yelpResult['categories'], :review_count => yelpResult['review_count'], :open_start => isOpenAndPrice.open_start, :open_end => isOpenAndPrice.open_end, :open => isOpenAndPrice.open, :distance => yelpResult['distance']})
          isOpenAndPrice.requests.each{ |req| Request.create(req)}  
        viableOptions += 1 if restaurant.open 
        end
      end
    end
    threshold = 15 if category == "restaurants"
    threshold = 5 if category != "restaurants"
    searchCategory(viableOptions, category,  [40000, (radius * 2)].min, location, dow, tod, parallel) if ((viableOptions < threshold) and (radius < 40000))
  end

  def self.nilEscape(str)
    if str == nil
      return "" 
    end
    return str
  end

  def self.getFormattedAddressFromYelpResult(yelpDict)
    nilEscape(yelpDict['name']) + ", " + nilEscape(yelpDict['location']['address'][0]) + ', '+ nilEscape(yelpDict['location']['city'])
    #nilEscape(yelpDict['name']) + ", " + nilEscape(yelpDict['location']['address'][0]) + ", " + nilEscape(yelpDict['location']['city']) + ", " + nilEscape(yelpDict['location']['state_code']) + " " + nilEscape(yelpDict['location']['postal_code']) + ", " + nilEscape(yelpDict['location']['country_code'])
  end

=begin
  def yelpToRestaurant(yelpDict, dow, time)
    isOpenAndPrice = MyGooglePlaces.isOpenAndPrice(getYelpFormattedAddress(yelpDict), dow, time)
    Restaurant.new(yelpDict['name'], isOpenAndPrice.price, yelpDict['location']['display_address'] * ",", yelpCategoriesToLECategories(yelpDict['categories']), yelpDict['mobile_url'], yelpDict['rating_img_url'], yelpDict['image_url'], yelpDict['rating'], yelpDict['categories'], yelpDict['review_count'])
  end
=end

end
