x = 0

def find(categories, invitation)
  x = 0
  loc = @invitation.location
  dow = @invitation.dayOfWeek
  tod = @invitation.timeOfDay
  categories.each do |category|
    #ActiveRecord::Base.connection.reconnect!
    searchCategory(0, category, 2000, loc, dow, tod)
  end
  puts "Final X is now #{x}"
#  puts "Creating restaurant records"
 # puts "Length of restaurants"
 # puts @restaurants.length
 # @restaurants.each{ |r| @invitation.restaurants.create(r) }
end


def searchCategory(viableOptions, category, radius, location, dow, tod,parallel = true)
  assoc_categories = RestaurantFinder.getAssociatedCategories(category)
  viableOptions = viableOptions
  categoryMutex = Mutex.new
  yelpResults = Yelp.getResults(location, assoc_categories, radius)
  rf = self
  Parallel.each(yelpResults) do |yelpResult|
    x += 1
    puts "X is now #{x}"
=begin
   #     ActiveRecord::Base.connection.reconnect!
        if (not exists(yelpResult))
          isOpenAndPrice = GooglePlaces.isOpenAndPrice(RestaurantFinder.getFormattedAddressFromYelpResult(yelpResult), dow, tod)
          restDict = {:name => yelpResult['name'], :price => isOpenAndPrice.price, :address => yelpResult['location']['display_address'] * ",", :url => yelpResult['mobile_url'], :rating_img => yelpResult['rating_img_url'], :snippet_img => yelpResult['image_url'], :rating => yelpResult['rating'], :categories => yelpResult['categories'], :review_count => yelpResult['review_count'], :open_start => isOpenAndPrice.openStart, :open_end => isOpenAndPrice.openEnd, :open => isOpenAndPrice.open, :distance => yelpResult['distance']}
          rf.restaurants_mutex.synchronize{
            puts "appending to length: "
            puts rf.restaurants.length
             rf.restaurants.append(restDict)
            puts "new length"
            puts rf.restaurants.length
          }
          categoryMutex.synchronize{viableOptions += 1} if restDict[:open]
        end 
=end

  #  searchCategory(viableOptions, category,  [40000, (radius * 2)].min, location, dow, tod, parallel) if ((viableOptions < 5) and (radius < 40000))
  end
end
         
