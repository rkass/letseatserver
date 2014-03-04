class Api::V1::SessionsController < ApplicationController
  #print "fucking here"
  #prepend_before_filter :authenticate_user!, :only => [:create ]
  
  #before_filter :ensure_params_exist

  respond_to :json
  
  def create
    #build_resource
    resource = User.find_for_database_authentication(:username => params[:username])
    return invalid_login_attempt unless resource
 
    if resource.valid_password?(params[:password])
      sign_in("user", resource)
      render :json=> {:auth_token=>resource.auth_token, :phone_number => resource.phone_number, :request=>"login"}
      return
    end
    invalid_login_attempt
  end
  
  def destroy
    sign_out(resource_name)
  end
 
  protected
  def ensure_params_exist
    return unless params[:user_login].blank?
    render :json=>{:success=>false, :message=>"missing user_login parameter"}, :status=>422
  end
 
  def invalid_login_attempt
    #warden.custom_failure!
    render :json=> {:success=>false, :message=>"Error with your login or password", :request=>"login"}, :status=>401
  end
end
