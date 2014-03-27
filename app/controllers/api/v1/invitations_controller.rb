require 'date'
class ::Api::V1::InvitationsController < ApplicationController
  
  def makeDateTime(dateString)
    split = dateString.split(',')
    monthString = ""
    monthNum = 0 
    if split[1].include? "Jan"
      monthString = "Jan"
      monthNum = 1 
    elsif split[1].include? "Feb"
      monthString = "Feb"
      monthNum = 2 
    elsif split[1].include? "Mar"
      monthString = "Mar"
      monthNum = 3 
    elsif split[1].include? "Apr"
      monthString = "Apr"
      monthNum = 4 
    elsif split[1].include? "May"
      monthString = "May"
      monthNum = 5 
    elsif split[1].include? "Jun"
      monthString = "Jun"
      monthNum = 6 
    elsif split[1].include? "Jul"
      monthString = "Jul"
      monthNum = 7 
    elsif split[1].include? "Aug"
      monthString = "Aug"
      monthNum = 8 
    elsif split[1].include? "Sep"
      monthString = "Sep"
      monthNum = 9 
    elsif split[1].include? "Oct"
      monthString = "Oct"
      monthNum = 10
    elsif split[1].include? "Nov"
      monthString = "Nov"
      monthNum = 11
    elsif split[1].include? "Dec"
      monthString = "Dec"
       monthNum = 12
    end 
    dayOfMonth = (split[1].gsub! monthString, '').to_i
    splitTime = split[2].split(':')
    hour = splitTime[0].to_i
    ampm = "PM"
    ampm = "AM" unless splitTime[1].include?"PM"
    hour += 12 if ampm == "PM" and hour != 12
    minutes = (splitTime[1].gsub! ampm, '').to_i
    year = Date.today.year
    year += 1 if Date.today.month > monthNum
    DateTime.new(year, monthNum, dayOfMonth, hour, minutes)
  end

  def respondNo
    Invitation.find(params[:id]).respondNo(User.find_by_auth_token(params[:auth_token]), params[:message])
    render :json => {:success => true}, :status=>201
    return
  end

  def respondYes
    r = Response.new(true, nil, params[:foodList], params[:location], params[:minPrice], params[:maxPrice])
    Invitation.find(params[:id]).respondYes(User.find_by_auth_token(params[:auth_token]), r)
    render :json => {:success => true}, :status=>201
    return
  end

  def yelpCategoriesToLECategories(lst)
    lst.flatten
  end

  def yelpToRestaurant(yelpDict, location, dow, time)
    isOpenAndPrice = GooglePlaces.isOpenAndPrice(location, yelpDict['name'], dow, time)
    Restaurant.new(yelpDict['name'], isOpenAndPrice.price, yelpDict['location']['display_address'] * ",", yelpCategoriesToLECategories(yelpDict['categories']), yelpDict['mobile_url'], yelpDict['rating_img_url'], yelpDict['image_url'])
  end
  #Give back 15 Restaurants and for each, supply the name, price, how far from the user,
  #address, type, url, rating image, percent match (serialized restaurant)
  def getRestaurants
    user = User.find_by_auth_token(params[:auth_token])
    invitash = Invitation.find(params[:id])
    loc = invitash.location
    #restaurants = Yelp.getResults(loc, invitash.categories[0])
    restaurants = Yelp.getResults("40.727676,-73.984593", "pizza")
    count = 0
    ret = []
    while count < 15
      ret.append(yelpToRestaurant(restaurants[count], loc, invitash.dayOfWeek, invitash.timeOfDay).serialize(invitash, user, []))
      count += 1
    end
#    puts "Returning from restaurants..."
 #   puts ret
    render :json => {:success => true, :restaurants => ret, :request => 'restaurants'}, :status => 201
    return
  end

  def create
    users = []
    users.append(User.find_by_auth_token(params[:auth_token]))
    if params[:numbers] != nil
      for number in params[:numbers]
        for u in User.find_all_by_phone_number(number)
          users.append(u)
        end
      end
    end
    p = Preferences.new(params[:foodList], params[:location], params[:minPrice], params[:maxPrice])
    scheduleTime = nil
    if (params[:scheduleAfter] == "15 Minutes")
      scheduleTime = DateTime.now + 15.minutes
    elsif (params[:scheduleAfter] == "30 Minutes")
      scheduleTime = DateTime.now + 30.minutes
    elsif (params[:scheduleAfter] == "1 Hour")
      scheduleTime = DateTime.now + 1.hours
    elsif (params[:scheduleAfter] == "5 Hours")
      scheduleTime = DateTime.now + 5.hours
    elsif (params[:scheduleAfter] == "24 Hours")
      scheduleTime = DateTime.now + 1.days
    end
    central = false
    central = true if (params[:central])
    invitation = Invitation.customNew(users, makeDateTime(params[:date]), scheduleTime,central, params[:message])
    if invitation.save
      invitation = Invitation.find(invitation.id)
      invitation.insertPreferences(User.find_by_auth_token(params[:auth_token]), p, creator = true)
      render :json => {:success => true, :number => invitation.id}, :status=>201
    else
      render :json => {:success => false}, :status =>422
    end
    return
  end

  def sort(user)
    for invitation in user.invitations.find_all_by_scheduled(false)
      if ((invitation.scheduleTime < DateTime.now) or (invitation.responses.count - invitation.responses.count(nil) >= minimum_attending))
        invitation.scheduled = true
        invitation.save
      end
    end
  end

  def getInvitationsOrMeals(meals)
    user = User.find_by_auth_token(params[:auth_token])
    sort(user)
    invitations = []
    for invitation in user.invitations.find_all_by_scheduled(meals)
      invitations.append(invitation.serialize(user))
    end
    render :json => {:success => true, :invitations => invitations}
    return
  end

  def getMeals
    getInvitationsOrMeals(true)
  end
  def get
    getInvitationsOrMeals(false)
  end    
end
