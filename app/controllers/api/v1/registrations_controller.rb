class Api::V1::RegistrationsController < ApplicationController
  respond_to :json
 
  def validate
    user = User.where(username: params[:username])[0]
    if user == nil
      validated = false
      render :json => {:validated => validated, :auth_token => "nil", :username => "nil", :request => "validate", :phone_number => "nil"}, :status => 201
    else
      validated = (user.auth_token == params[:auth_token])
      render :json=> {:validated=> validated, :auth_token => user.auth_token, :username => user.username, :request=>"validate", :phone_number => user.phone_number}    , :status=>201
    end
    return
  end

  def create 
    if params[:facebook_id] != nil
      puts "not nil"
      user = User.where(facebook_id: params[:facebook_id])
      if user == nil
        o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
        password = (0...50).map { o[rand(o.length)] }.join
        username = (0...50).map { o[rand(o.length)] }.join
        user = User.new(:username => username, :password => password, :auth_token => Digest::SHA1.hexdigest(password + username), :facebook_id => params[:facebook_id])
      end
      render :json=> {:auth_token=> user.auth_token, :phone_number => user.phone_number, :username => user.username, :request=>"sign_upfb", :facebook_id => params[:facebook_id]}, :status=>201
      return
    else 
      puts "not nil"
    end
    user = User.where(phone_number: phoneStrip(params[:phoneNumber]))[0]
    if user == nil 
      o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
      password = (0...50).map { o[rand(o.length)] }.join
      username = (0...50).map { o[rand(o.length)] }.join
      user = User.new(:username => username, :password => password, 
      :phone_number => phoneStrip(params[:phoneNumber]), :auth_token => Digest::SHA1.hexdigest(password + username))
    end
    invs = Invitation.where("invitees like ?", "%" + user.phone_number + "%")
    if user.save
      sendRegistrationText(user.auth_token, '+1' + user.phone_number)
      for inv in invs
        inv.users.append(user)
        inv.save
        inv = Invitation.find(inv.id)
        newresponses = []
        resp = inv.responses.reverse
        cnt = 0
        while (cnt < inv.users.length)
          if (inv.users[cnt].id == user.id)
            newresponses.append(nil)
          else
            newresponses.append(resp.pop())
          end
          cnt += 1
        end
        inv.sortScheduled(nil)
        inv.responses = newresponses
        inv.save
      end
      user.save    
      render :json=> {:auth_token=> user.auth_token, :phone_number => user.phone_number, :username => user.username, :request=>"sign_up"}, :status=>201
      return
    else
#     warden.custom_failure!
      render :json=> {:success => "false", :request=>"sign_up"},  :status=>422
      return
    end
  end
end
