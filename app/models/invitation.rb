require Rails.root.join('app', 'models', 'preferences.rb').to_s
require Rails.root.join('app', 'models', 'response.rb').to_s

class Invitation < ActiveRecord::Base
  serialize :responses
  serialize :restaurants
  validate :validator
  has_and_belongs_to_many :users, :order => :id
  def self.customNew(users, time, scheduleTime, central,minimum_attending, message = nil)
    i = Invitation.new
    i.users = users
    i.responses = ([nil] * (users.length))
    i.time = time
    i.scheduleTime = scheduleTime
    i.central = central
    i.scheduled = false
    i.message = message
    i.minimum_attending = minimum_attending
    i
  end
  def validator
    errors.add(:users, "Supply a creator") if self.users.length < 1
    errors.add(:responses, "Provide a response for all invitees and initialize it to nil") if (self.responses.length != self.users.length)
    errors.add(:time, "Provide a time for the invite") if (self.time == nil)
  end
  def going(arguser)
    (self.creator_index == self.users.index(arguser)) or (responded(arguser) and responses[self.users.index(arguser)].going)
  end
  def responded(arguser)
    self.responses[self.users.index(arguser)] != nil
  end
  def insertPreferences(user, preferences, creator = false)
   self.creator_index = self.users.index(user) if creator
   self.responses[self.users.index(user)] = preferences
   self.save 
  end
  def dayOfWeek
    self.time.wday
  end
  def timeOfDay
    h = self.time.hour.to_s
    h = "0" + h if h.length == 1
    min = self.time.min.to_s
    min = "0" + min if min.length == 1
    h + min
  end
  def location
    return self.responses[self.creator_index].location if (not central) 
    lat = 0
    lng = 0
    cnt = 0
    grandCnt = 0
    for resp in self.responses  
      if resp != nil and ((grandCnt == self.creator_index) or resp.going)
        lat += resp.location.split(",")[0].to_f
        lng += resp.location.split(",")[1].to_f
        cnt += 1
      end
      grandCnt += 1
    end
    lat = lat / cnt
    lng = lng / cnt
    lat.to_s + "," + lng.to_s
  end
  def categories
    cats = {}
    cnt = 0
    for resp in self.responses
      if resp != nil and ((cnt == self.creator_index) or resp.going)
        inner_cnt = 0
        for t in resp.types_list
          if cats.has_key?t
            cats[t] += 7 - inner_cnt
          else
            cats[t] = 7 - inner_cnt
          end
          inner_cnt += 1
        end
      end
      cnt += 1
    end
    ret = []
    for cat in cats.sort_by{|k,v| v}
      ret.append(cat[0])
    end
    ret
  end
  def respondNo(arguser, message)
    responses = self.responses
    responses[self.users.index(arguser)] = Response.new(false, message, nil, nil, nil)
    self.responses = responses
    self.scheduleTime = DateTime.now + 5.minutes if ((self.responses.count - self.responses.count(nil) == self.responses.count) and (self.responses.count > 1))
    self.save
  end
  def respondYes(arguser, response)
    responses = self.responses
    responses[self.users.index(arguser)] = response
    self.responses = responses
    self.scheduleTime = DateTime.now + 5.minutes if ((self.responses.count - self.responses.count(nil) == self.responses.count) and (self.responses.count > 1))
    self.save
  end
  def serializeTime(time)
    ret = time.to_formatted_s(:rfc822)
    index = ret.index("+")
    index = ret.index("-") if index == nil
    ret[0..index - 2]
  end

  def serialize(arguser, withRestaurants = false)
    ret = {}
    ret["people"] = []
    ret["responses"] = []
    ret["messages"] = []
    ret["preferences"] = []
    if withRestaurants
      ret["restaurants"] = []
    end
    self.with_lock do
      for user in self.users
        ret["people"].append(user.phone_number)
      end
      count = 0
      for response in self.responses
        if count == self.creator_index
          ret["responses"].append("yes")
          ret["messages"].append("")
        elsif self.responses[count] == nil
          ret["responses"].append("undecided")
          ret["messages"].append("")
        elsif self.responses[count].going
          ret["responses"].append("yes")
          ret["messages"].append("")
        else
          ret["responses"].append("no")
          ret["messages"].append(self.responses[count].message)
        end
        if response == nil
          ret["preferences"].append([])
        else
          ret["preferences"].append(response.types_list)
        end
        count += 1
      end
      ret["time"] = self.time
      ret["message"] = self.message
      ret["id"] = self.id
      ret["iResponded"] = self.responded(arguser)
      ret["creatorIndex"] = self.creator_index
      ret["central"] = self.central
      if (self.scheduleTime != nil and self.scheduleTime < self.time)
        ret["scheduleTime"] = self.scheduleTime
      else  
        ret["scheduleTime"] = ret["time"]
      end
      ret["scheduled"] = self.scheduled
      end
      if withRestaurants
        if self.restaurants != nil
          self.restaurants.each_key do |key|
            ret["restaurants"].append(key.serialize(self.restaurants[key], user))
          end
        end
        ret.updatingRecommendations = self.updatingRecommendations
      end
    ret["time"] = self.transformTime(ret["time"]) 
    ret["scheduleTime"] = self.transformTime(ret["scheduleTime"])
    ret
  end
  def yelpCategoriesToLECategories(lst)
    lst.flatten
  end 
  def getYelpFormattedAddress(yelpDict)
    yelpDict['name'] + ", " + yelpDict['location']['address'][0] + ", " + yelpDict['location']['city'] + ", " + yelpDict['location']['state_code'] + " " + yelpDict['location']['postal_code'] + ", " + yelpDict['location']['country_code']
   end 
  def yelpToRestaurant(yelpDict, location, dow, time)
    isOpenAndPrice = GooglePlaces.isOpenAndPrice(getYelpFormattedAddress(yelpDict), dow, time)
    Restaurant.new(yelpDict['name'], isOpenAndPrice.price, yelpDict['location']['display_address'] * ",", yelpCategoriesToLECategories(yelpDict['categories']), yelpDict['mobile_url'], yelpDict['rating_img_url'], yelpDict['image_url'])
  end 
  def updateRestaurants
    #in future replace first arg with self.location
    ret = self.restaurants
    if ret == nil
      restaurants = Yelp.getResults("40.727676,-73.984593", "pizza", 15) 
      count = 0 
      ret = {}
      while count < 15
        ret[yelpToRestaurant(restaurants[count], loc, invitash.dayOfWeek, invitash.timeOfDay)] = []
        count += 1
      end
      self.restaurants = ret
    end
    self.with_lock do
      self.update_attributes(:restaurants => ret, :updatingRecommendations => self.updatingRecommendations - 1)
    end
  end 
  def vote(user, restaurant)
    self.with_lock do
      self.restaurants.each_key do |key|
        if key.equals(restaurant)
          self.restaurants[key].append(user.id)
          break
        end
      end
      self.save
    end
  end   
  def unvote(user, restaurant)
    self.with_lock do
      self.restaurants.each_key do |key|
        if key.equals(restaurant)
          self.restaurants[key].delete(user.id)
          break
        end
      end
      self.save 
    end
  end   
  def saveAndUpdateRecommendations
    self.with_lock do
      ret = self.update_attributes(:updatingRecommendations => self.updatingRecommendations + 1)
    self.delay.updateRestaurants
    ret
  end
end
