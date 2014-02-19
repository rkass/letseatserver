class Api::V1::RegistrationsController < ApplicationController
  respond_to :json
  
  def create
    user = User.new(:username => params[:username], :password => params[:password], 
      :phone_number => phoneStrip(params[:phoneNumber]), :auth_token => Digest::SHA1.hexdigest(params[:username] + params[:password]))
    if user.save
      render :json=> {:auth_token=> user.auth_token, :request=>"sign_up"}, :status=>201
      return
    else
#      warden.custom_failure!
      render :json=> {:success => "false", :request=>"sign_up"},  :status=>422
      return
    end
  end
end
