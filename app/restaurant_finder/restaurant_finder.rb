class RestaurantFinder

  def self.find(categories, invitation)
    Parallel.each(categories) do |category|
      searchCategory(0, category, invitation, 2000)
    end
  end

  def self.searchCategory(viableOptions, category, invitation, radius)
    viableOptions = viableOptions
    categoryMutex = Mutex.new
    yelpResults = Yelp.getResults(invitation.location, category, radius)
    Parallel.each(yelpResults) do |yelpResult|
      ActiveRecord::Base.connection.reconnect!
      if (not invitation.restaurants.where(url:yelpResult['mobile_url']).exists?)
        isOpenAndPrice = GooglePlaces.isOpenAndPrice(getFormattedAddressFromYelpResult(yelpResult), invitation.dayOfWeek, invitation.timeOfDay)       
        restaurant = invitation.restaurants.create({:name => yelpResult['name'], :price => isOpenAndPrice.price, :address => yelpResult['location']['display_address'], :url => yelpResult['mobile_url'], :rating_img => yelpResult['rating_img_url'], :snippet_img => yelpResult['image_url'], :rating => yelpResult['rating'], :categories => yelpResult['categories'], :review_count => yelpResult['review_count'], :open_start => isOpenAndPrice.openStart, :open_end => isOpenAndPrice.openEnd, :open => isOpenAndPrice.open, :distance => yelpResult['distance'])}
        categoryMutex.synchronize{viableOptions += 1} if restaurant.open
      end 
    end
    searchCategory(viableOptions, category, location, [40000, (radius * 2)].min) if ((viableOptions < 5) and (radius < 40000))
  end


  def self.getFormattedAddressFromYelpResult(yelpDict)
    yelpDict['name'] + ", " + yelpDict['location']['address'][0] + ", " + yelpDict['location']['city'] + ", " + yelpDict['location']['state_code'] + " " + yelpDict['location']['postal_code'] + ", " + yelpDict['location']['country_code']
  end

=begin
  def yelpToRestaurant(yelpDict, dow, time)
    isOpenAndPrice = GooglePlaces.isOpenAndPrice(getYelpFormattedAddress(yelpDict), dow, time)
    Restaurant.new(yelpDict['name'], isOpenAndPrice.price, yelpDict['location']['display_address'] * ",", yelpCategoriesToLECategories(yelpDict['categories']), yelpDict['mobile_url'], yelpDict['rating_img_url'], yelpDict['image_url'], yelpDict['rating'], yelpDict['categories'], yelpDict['review_count'])
  end
=end

end
