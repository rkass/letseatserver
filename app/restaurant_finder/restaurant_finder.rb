class RestaurantFinder

=begin
  def getYelpFormattedAddress(yelpDict)
    yelpDict['name'] + ", " + yelpDict['location']['address'][0] + ", " + yelpDict['location']['city'] + ", " + yelpDict['location']['state_code'] + " " + yelpDict['location']['postal_code'] + ", " + yelpDict['location']['country_code']
   end
  def yelpToRestaurant(yelpDict, dow, time)
    isOpenAndPrice = GooglePlaces.isOpenAndPrice(getYelpFormattedAddress(yelpDict), dow, time)
    Restaurant.new(yelpDict['name'], isOpenAndPrice.price, yelpDict['location']['display_address'] * ",", yelpCategoriesToLECategories(yelpDict['categories']), yelpDict['mobile_url'], yelpDict['rating_img_url'], yelpDict['image_url'], yelpDict['rating'], yelpDict['categories'], yelpDict['review_count'])
  end
=end

end
