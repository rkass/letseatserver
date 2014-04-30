require Rails.root.join('app', 'models', 'preferences.rb').to_s
require Rails.root.join('app', 'models', 'response.rb').to_s

class Invitation < ActiveRecord::Base
  serialize :responses
  serialize :invitees
  serialize :new_preferences
  
  validate :validator

  
  has_and_belongs_to_many :users, :order => :id
  has_many :restaurants, :order => 'open DESC, percent_match DESC'

  def self.customNew(users, time, scheduleTime, central,minimum_attending, seconds_from_gmt, invitees, message = nil)
    i = Invitation.new
    i.users = users
    i.responses = ([nil] * (users.length))
    i.time = time
    i.scheduleTime = scheduleTime
    i.central = central
    i.scheduled = false
    i.message = message
    i.seconds_from_gmt = seconds_from_gmt
    i.minimum_attending = minimum_attending
    i.invitees = []
    for inv in invitees
      i.invitees.append(ApplicationController::phoneStrip(inv))
    end
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
  def declined(arguser)
    (self.creator_index != self.users.index(arguser) and responded(arguser) and (not responses[self.users.index(arguser)].going))
  end
  def responded(arguser)
    self.responses[self.users.index(arguser)] != nil
  end
  def preferencesForUser(user)
    self.responses[self.users.index(user)]
  end
  def insertPreferences(user, preferences, creator = false)
   self.new_preferences = preferences
   puts "New preferences inserted..types list"
    puts self.new_preferences.types_list
   self.creator_index = self.users.index(user) if creator
   self.responses[self.users.index(user)] = preferences
   self.save 
  end
  def dayOfWeek
    (self.time + self.seconds_from_gmt.seconds).wday
  end
  def timeOfDay
    newt = self.time + self.seconds_from_gmt.seconds
    h = newt.hour.to_s
    h = "0" + h if h.length == 1
    min = newt.min.to_s
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
    responses[self.users.index(arguser)] = Response.new(false, message, nil, nil, nil, nil)
    self.responses = responses
    self.scheduleTime = DateTime.now + 5.minutes if ((self.responses.count - self.responses.count(nil) == self.responses.count) and (self.responses.count > 1))
    self.save
  end
  def respondYes(arguser, response)
    responses = self.responses
    responses[self.users.index(arguser)] = response
    self.new_preferences = response
    self.responses = responses
    self.save
    self.sortScheduled(arguser)
  end
  def serializeTime(time)
    ret = time.to_formatted_s(:rfc822)
    index = ret.index("+")
    index = ret.index("-") if index == nil
    ret[0..index - 2]
  end

  def serialize(arguser)
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
          ret["restaurants"] = self.restaurants.where(open:true).first(15).map do |rest|
            rest.serialize(arguser)
          end
        end
      end
    ret["updatingRecommendations"] = self.updatingRecommendations
    ret["time"] = self.serializeTime(ret["time"] + self.seconds_from_gmt.seconds)
    ret["scheduleTime"] = self.serializeTime(ret["scheduleTime"])
    ret
  end

  def sortScheduled(excludeUser)
    orig = self.scheduled
    date = self.scheduleTime
    date = self.time if (date == nil or self.time < date)
    if ((date < DateTime.now) or (self.responses.count - self.responses.count(nil) == self.responses.count))
      self.update_attributes(:scheduled => true)
      cnt = 0
      for u in self.users
          u.sendPush(self, true) if (u.device_token != nil and u.device_token != "(null)" and (not self.declined(u)) and (u != excludeUser) and (!orig))    
          cnt += 1
      end 
    else
      self.update_attributes(:scheduled => false)
    end 
  end

  def newCategories
    ret = self.new_preferences.types_list.dup
    return ret if ret == []
    for pref in (self.responses.select{|r| r!= nil})
      if pref != self.new_preferences
        for t in pref.types_list
          ret.delete(t)
          return ret if ret == []
        end 
      end
    end
    ret
  end

  def allCategories
    ret = []
    for pref in (self.responses.select{|r| r!= nil})
      for t in pref.types_list
        ret.append(t) if (not ret.include?t)
      end
    end
    ret
  end 
    
  def updateRestaurants(withVote)
    rf = RestaurantFinder.new(self)
    if not self.central
      for r in self.restaurants
        if r.votes != []
          r.recalculateDistance
        else
          r.destroy
        end
      end
      rf.find(allCategories)
      rf.fillGaps
    else
      rf.find(newCategories)
      rf.fillGaps
    end
    self.restaurants.each{ |r| r.compute(1, 1, 1, 1)}
    self.with_lock do
      puts "Decrementing id: #{self.id} from current value of #{self.updatingRecommendations}"     
      self.update_attributes(:updatingRecommendations => self.updatingRecommendations - 1)
    end
  end
     
  def vote(user, input_url)
    preferences = preferencesForUser(user)
    voted_restaurant = nil
    other_restaurants = []
    self.with_lock do
      for r in self.restaurants
        if r.url == input_url
          r.votes.append(user.id)
          r.save
          voted_restaurant = r.serialize(user)
        else
          other_restaurants.append(r.serialize(user))
        end
      end
      self.save
    end
    Vote.create(:preferences => preferences, :voted_restaurant => voted_restaurant, :other_restaurants => other_restaurants)
  end 
  
  def unvote(user, restaurant)
    self.with_lock do
      for r in self.restaurants
        if r.url == input_url 
          r.votes.delete(user.id)
          r.save
          break
        end
      end 
      self.save 
    end
  end   
  def saveAndUpdateRecommendations(withVote)
    ret = nil
    self.with_lock do
      ret = self.update_attributes(:updatingRecommendations => self.updatingRecommendations + 1)
    end
    self.delay.updateRestaurants(withVote)
    ret
  end
  def hundredSerial
    r = []
    #m = Mutex.new
    cnt = 0
    while (cnt < 100)
      res = Yelp.getResults("40.727676,-73.984593", "pizza", 2000)
     # m.synchronize{
        r.append(res)
     # }
      cnt += 1
    end
  end
  def hundredMapped
    r = []
    m = Mutex.new
    Parallel.each([0]*100) do |chunk|
      res = Yelp.getResults("40.727676,-73.984593", "pizza", 2000)
      m.synchronize{
        r.append(res)
      }
    end
  end
  def hundredNoProcesses
    r = []
    m = Mutex.new
    Parallel.map([0]*100, :in_processes=>0) do |chunk|
      res = Yelp.getResults("40.727676,-73.984593", "pizza", 2000)
      m.synchronize{
        r.append(res)
      }   
    end 
  end 
  def hundredNoThreading
    r = []
    m = Mutex.new
    Parallel.map([0]*100, :in_threads=>0) do |chunk|
      res = Yelp.getResults("40.727676,-73.984593", "pizza", 2000)
      m.synchronize{
        r.append(res)
      }   
    end 
  end 
  def benchmarkRestFinder
    rf = RestaurantFinder.new(self, [])
    puts "Running restaurant finder with parallelism..."
    x = Benchmark.measure{rf.find(self.responses[0].types_list)}
    puts "Time Results..."
    puts x
    puts "Generating #{self.restaurants.length} restaurants"
    puts "Running restaurant finder without parallelism...starting from #{self.restaurants.length} restaurants..."
    x = Benchmark.measure{rf.find(self.responses[0].types_list, false)}
    puts "Time Results..."
    puts x
    puts "Generating #{self.restaurants.length} restaurants"
=begin
    x = Benchmark.measure{hundredSerial}
    print x
    print "Running one hundred requests using map..."
    x = Benchmark.measure{hundredMapped}
    print x
=end
  end
end
