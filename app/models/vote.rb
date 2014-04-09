class Vote < ActiveRecord::Base
serialize :preferences
serialize :voted_restaurant
serialize :other_restaurants
end
