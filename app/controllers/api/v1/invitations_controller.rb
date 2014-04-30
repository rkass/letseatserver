require 'date'
class ::Api::V1::InvitationsController < ApplicationController
  
  def makeDateTime(dateString, secondsFromGMT)
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
    hour -= 12 if ampm == "AM" and hour == 12
    minutes = (splitTime[1].gsub! ampm, '').to_i
    year = (DateTime.now).to_date.year
    year += 1 if (DateTime.now + secondsFromGMT.seconds).to_date.month > monthNum
    DateTime.new(year, monthNum, dayOfMonth, hour, minutes) - secondsFromGMT.seconds
  end
  def respondWithInvitation(call, user, invitation)
    withRestaurants = false
    withRestaurants = true if self.updatingRecommendations == 0
    render :json => {:success => true, :call => call, :invitation => invitation.serialize(user, withRestaurants)}
  end    
  def respondNo
    Invitation.find(params[:id]).respondNo(User.find_by_auth_token(params[:auth_token]), params[:message])
    render :json => {:success => true, :call => "respond_no"}, :status=>201
    return
  end
  def respondYes
    print "responding yest"
    r = Response.new(true, nil, params[:foodList], params[:location], params[:minPrice], params[:maxPrice])
    invitation = Invitation.find(params[:id])
    user = User.find_by_auth_token(params[:auth_token])
    invitation.respondYes(user, r)
    print "back from model call"
    invitation.saveAndUpdateRecommendations(false)
    print "back from save and update call"
    respondWithInvitation("respond_yes", user, invitation)
  end
  def getInvitation
    user = User.find_by_auth_token(params[:auth_token])
    invitash = Invitation.find(params[:id])
    invitash.sortScheduled(user)
    respondWithInvitation("get_invitation", user, invitash)
  end
 def vote
    user = User.find_by_auth_token(params[:auth_token])
    i = Invitation.find(params[:invitation])
    i.vote(user, params[:url])
    i.saveAndUpdateRecommendations(true)
    respondWithInvitation("cast_vote", user, i)
  end
  def unvote
    user = User.find_by_auth_token(params[:auth_token])
    i = Invitation.find(params[:invitation])
    restaurant = Restaurant.new(params[:name], params[:price], params[:address], params[:types], params[:url], params[:ratingImg], params[:snippetImg])
    i.unvote(user, restaurant)
    i.saveAndUpdateRecommendations(true)
    respondWithInvitation("cast_unvote", user, i)
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
    invitees  = params[:invitees]
    invitees = [] if invitees == nil
    invitation = Invitation.customNew(users, makeDateTime(params[:date], params[:secondsFromGMT]), scheduleTime,central, params[:minPeople], params[:secondsFromGMT], invitees, params[:message])
    if invitation.save
      invitation = Invitation.find(invitation.id)
      invitation.insertPreferences(User.find_by_auth_token(params[:auth_token]), p, creator = true)
      cnt = 0
      for u in invitation.users
        u.sendPush(invitation, false) if (cnt != invitation.creator_index and u.device_token != nil and u.device_token != "(null)")
        cnt += 1
      end
      for num in invitation.invitees
        sendInviteText(params[:foodList], invitation.time, num)
      end
      invitation.saveAndUpdateRecommendations(false)
      respondWithInvitation("create_invitation", User.find_by_auth_token(params[:auth_token]), invitation) 
    else
      render :json => {:success => false}, :status =>422
    end
  end
  def sort(user)
    for invitation in user.invitations.find_all_by_scheduled(false)
      invitation.sortScheduled(user)
      #date = invitation.scheduleTime
      #date = invitation.time if (date == nil or invitation.time < date)
      #if ((date < DateTime.now) or (invitation.responses.count - invitation.responses.count(nil) == invitation.responses.count))
      #  invitation.update_attributes(:scheduled => true)
      #end
    end
  end
  def getInvitationsOrMeals(call)
    user = User.find_by_auth_token(params[:auth_token])
    sort(user)
    invitations = []
    meals = (call == "get_meals")
    for invitation in user.invitations.find_all_by_scheduled(meals)
      invitations.append(invitation.serialize(user)) if ((not invitation.declined(user)) or (not meals))
    end
    render :json => {:success => true, :invitations => invitations, :call => call}
    return
  end
  def getMeals
    getInvitationsOrMeals("get_meals")
  end
  def get
    getInvitationsOrMeals("get_invitations")
  end    
end
