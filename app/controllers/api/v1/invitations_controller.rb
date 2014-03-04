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
    p = Preferences.new(params[:foodList], params[:location], params[:price])
    invitation = Invitation.customNew(users, makeDateTime(params[:date]), params[:message])
    if invitation.save
      invitation = Invitation.find(invitation.id)
      invitation.insertPreferences(User.find_by_auth_token(params[:auth_token]), p, creator = true)
      render :json => {:success => true}, :status=>201
    else
      render :json => {:success => false}, :status =>422
    end
    return
  end

  def get
    user = User.find_by_auth_token(params[:auth_token])
    puts "id"
    user.id
    invitations = []
    for invitation in user.invitations
      invitations.append(invitation.serialize(user))
    end
    render :json => {:success => true, :invitations => invitations}
    return
  end    
end
