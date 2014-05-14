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

  @@categories_dict = {"subUkrainian"=>"ukrainian", "subLatin American"=>"latin", "subBrazilian"=>"brazilian", "subSingaporean"=>"singaporean", "subRussian"=>"russian", "subFood Court"=>"food_court", "subCambodian"=>"cambodian", "subBritish"=>"british", "subAustralian"=>"australian", "subIndonesian"=>"indonesian", "subSoup"=>"soup", "subModern European"=>"modern_european", "subCupcakes"=>"cupcakes", "subAfrican"=>"african", "subPakistani"=>"pakistani", "subMalaysian"=>"malaysian", "subCheesesteaks"=>"cheesesteaks", "subCantonese"=>"cantonese", "subArabian"=>"arabian", "subBrunch"=>"breakfast_brunch", "subDominican"=>"dominican", "subCoffee & Tea"=>"coffee", "subVenezuelan"=>"venezuelan", "subCrepery"=>"creperies", "subAfghan"=>"afghani", "subTurkish"=>"turkish", "subPolish"=>"polish", "subPortuguese"=>"portuguese", "subDiners"=>"diners", "subChinese"=>"chinese", "subSouth African"=>"southafrican", "subSoul Food"=>"soulfood", "Spanish"=>"spanish", "subLebanese"=>"lebanese", "subThai"=>"thai", "subBrasseries"=>"brasseries", "subGastropubs"=>"gastropubs", "subMediterranean"=>"mediterranean", "subIndian"=>"indpak", "subHaitian"=>"haitian", "subAsian Fusion"=>"asianfusion", "subGluten Free"=>"gluten_free", "subMongolian"=>"mongolian", "subBurgers"=>"burgers", "subCafeteria"=>"cafeteria", "subHot Dogs"=>"hotdog", "subCatalan"=>"catalan", "subSalvadoran"=>"salvadoran", "subPuetro Rican"=>"puertorican", "subIrish"=>"irish", "subKosher"=>"kosher", "subMiddle Eastern"=>"middleeastern", "subColombian"=>"colombian", "subAmerican"=>"newamerican", "subDeli"=>"delis", "subFondue"=>"fondue", "subJapanese"=>"japanese", "subDonuts"=>"donuts", "subArmenian"=>"armenian", "subPeruvian"=>"peruvian", "subFish & Chips"=>"fishnchips", "subGerman"=>"german", "subScottish"=>"scottish", "subSteakhouse"=>"steak", "subBelgian"=>"belgian", "subCuban"=>"cuban", "subSandwiches"=>"sandwiches", "subJuice Bar"=>"juicebars", "subVegan"=>"vegan", "subFilipino"=>"filipino", "subSlovakian"=>"slovakian", "subTapas"=>"tapasmallplates", "subAustrian"=>"austrian", "subFalafel"=>"falafel", "subSzechuan"=>"szechuan", "subCzech"=>"czech", "subSouthern Food"=>"southern", "subGelato"=>"gelato", "subEthiopian"=>"ethiopian", "subChicken Wings"=>"chicken_wings", "subPersian Iranian"=>"persian", "subBBQ"=>"bbq", "subSpanish"=>"spanish", "subDim Sum"=>"dimsum", "subSeafood"=>"seafood", "subFrench"=>"french", "subBangladeshi"=>"bangladeshi", "subVietnamese"=>"vietnamese", "subTrinidadian"=>"trinidadian", "subBagels"=>"bagels", "subScandinavian"=>"scandinavian", "subBasque"=>"basque", "subBuffet"=>"buffets", "subVegetarian"=>"vegetarian", "subHungarian"=>"hungarian", "subCajun"=>"cajun", "subDessert"=>"desserts", "subSushi"=>"sushi",  "subHawaiian"=>"hawaiian", "subEgyptian"=>"egyptian", "subMoroccan"=>"moroccan", "subCaribbean"=>"caribbean", "subRaw"=>"raw_food", "subFood Stand"=>"foodstands", "subComfort Food"=>"comfortfood", "subCafe"=>"cafes", "subTex-Mex"=>"tex-mex", "subLaotian"=>"laotian", "subArgentine"=>"argentine", "subSenegalese"=>"senegalese", "subItalian"=>"italian", "subGreek"=>"greek", "subBurmese"=>"burmese", "subShanghainese"=>"shanghainese", "subIberian"=>"iberian", "subHimalayan/Nepalese"=>"himalayan", "subTaiwanese"=>"taiwanese", "subPizza"=>"pizza", "subIce Cream/Frozen Yogurt"=>"icecream", "subKorean"=>"korean", "subHot Pot"=>"hotpot", "subMexican"=>"mexican", "subFast Food"=>"hotdogs", "subHalal"=>"halal"}
  
  #restaurants is a dictionary representing restaurants
  attr_accessor :invitation, :client
  def initialize(invitation)
    @invitation = invitation
    @client = Places::Client.new({:api_key => MyGooglePlaces.api_key})
  end 

  def self.translationDict
    @@translation_dict
  end

  def self.categoriesDict
    @@categories_dict
  end

  def self.getAssociatedCategories(category)
    translationDict[category.downcase] 
  end

  def self.getLECategory(yelpCategory)
    translationDict.each{ |k, v| return k if (v.include?yelpCategory)}
    return nil
  end

  def find(newPrefsOnly, parallel = true)
    loc = @invitation.location
    dow = @invitation.dayOfWeek
    tod = @invitation.timeOfDay
    if parallel
      if newPrefsOnly
        vo = 0
        twos = @invitation.new_preferences.getCategoriesRated(2)
        puts "Searching twos"
        puts twos
        vo = self.searchCategory(0, twos, 2000, loc, dow, tod) if twos != ""
        if vo <= 10
          ones = @invitation.new_preferences.getCategoriesRated(1)
          puts "searching ones"
          puts ones
          self.searchCategory(0, ones, 2000, loc, dow, tod) if ones != ""
        end
      else
        for r in @invitation.responses.select{|r| r!= nil}
          vo = 0
          twos = r.getCategoriesRated(2)
          vo = self.searchCategory(0, twos, 2000, loc, dow, tod) if twos != ""
          if vo <= 10
            ones = r.getCategoriesRated(1)
            self.searchCategory(0, ones, 2000, loc, dow, tod) if ones != ""
          end
        end
      end
    else
      categories.each do |category|
        searchCategory(0, category, 2000, loc, dow, tod,false)
      end
    end
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
      r.open = RestaurantFinder.isOpen(r.open_start.to_i, r.open_end.to_i, @invitation.time.to_i) if r.open == nil
      r.price = avg_price if r.price == nil
      r.save
    end
  end

  def self.isOpen(openStart, openEnd, time)
    openEnd += 24 if openEnd <= 6
    time >= openStart and time <= openEnd
  end
  
  #From SO  
  def self.distance a, b
    rad_per_deg = Math::PI/180  # PI / 180
    rkm = 6371                  # Earth radius in kilometers
    rm = rkm * 1000             # Radius in meters

    dlon_rad = (b[1]-a[1]) * rad_per_deg  # Delta, converted to rad
    dlat_rad = (b[0]-a[0]) * rad_per_deg

    lat1_rad, lon1_rad = a.map! {|i| i * rad_per_deg }
    lat2_rad, lon2_rad = b.map! {|i| i * rad_per_deg }

    a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
    c = 2 * Math.asin(Math.sqrt(a))

    rm * c # Delta in meters
  end
  
  def self.getCoordinates(address)
    res = HTTParty.get("https://maps.googleapis.com/maps/api/geocode/json?address=#{address}&sensor=false&key=AIzaSyBITjgfUC0tbWp9-0SRIRR-PYAultPKDbA")
    lat = ""
    lng = ""
    lat = res.parsed_response['results'][0]['geometry']['location']['lat'] if (res.parsed_response != nil and res.parsed_response['results'] != nil and res.parsed_response['results'][0]['geometry'] != nil)
    lng = res.parsed_response['results'][0]['geometry']['location']['lng'] if (res.parsed_response != nil and res.parsed_response['results'] != nil and res.parsed_response['results'][0]['geometry'] != nil)
    "#{lat.to_s},#{lng.to_s}"
  end

  def searchCategory(viableOptions, category, radius, location, dow, tod,parallel = true)
    assoc_categories = category
    viableOptions = viableOptions
    yelpResults = Yelp.getResults(location, assoc_categories, radius)
    lat = @invitation.location.split(',')[0].to_f
    lng = @invitation.location.split(',')[1].to_f
    if parallel
      ActiveRecord::Base.connection.disconnect!
      results = Parallel.map(yelpResults) do |yelpResult|
        if (not @invitation.restaurants.where(url:yelpResult['mobile_url']).exists?)
          isOpenAndPrice = MyGooglePlaces.isOpenAndPrice(RestaurantFinder.getFormattedAddressFromYelpResult(yelpResult), dow, tod, @client, lat, lng, yelpResult['name'])
          os = OpenStruct.new
          os.restaurant = {:name => yelpResult['name'], :price => isOpenAndPrice.price, :address => yelpResult['location']['display_address'] * ",", :url => yelpResult['mobile_url'], :rating_img => yelpResult['rating_img_url'], :snippet_img => yelpResult['image_url'], :rating => yelpResult['rating'], :categories => yelpResult['categories'], :review_count => yelpResult['review_count'], :open_start => isOpenAndPrice.open_start, :open_end => isOpenAndPrice.open_end, :open => isOpenAndPrice.open, :distance => yelpResult['distance'], :types_list => yelpResult['categories'].map{|p| p[0]}}
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
    if ((viableOptions < threshold) and (radius < 40000))
      searchCategory(viableOptions, category,  [39000, (radius * 2)].min, location, dow, tod, parallel)
    end
    viableOptions
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
