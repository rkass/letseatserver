class Api::V1::RegistrationsController < ApplicationController
  respond_to :json
  
  def create
    user = User.new(:username => params[:username], :password => params[:password], 
      :phone_number => phoneStrip(params[:phoneNumber]), :auth_token => Digest::SHA1.hexdigest(params[:username] + params[:password]))
    invs = Invitation.where("invitees like ?", "%" + user.phone_number + "%")
    if user.save
      print "Successfully saved"
      for inv in invs
        inv.users.append(user)
        inv.save
        inv = Invitation.find(inv.id)
        newresponses = []
        resp = inv.responses
        cnt = 0
        while (cnt < inv.users.length)
          if (inv.users[cnt].id == user.id)
            newresponses.append(nil)
          else
            newresponses.append(resp[cnt])
            cnt += 1
          end
        end
      end
      print "Resaving"
      user.save    
      render :json=> {:auth_token=> user.auth_token, :phone_number => user.phone_number, :request=>"sign_up"}, :status=>201
      return
    else
#     warden.custom_failure!
      render :json=> {:success => "false", :request=>"sign_up"},  :status=>422
      return
    end
  end
end
