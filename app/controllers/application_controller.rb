class ApplicationController < ActionController::Base
  before_filter :configure_permitted_parameters, if: :devise_controller?

  protected

  def validateUser(auth_token)
    User.find_by_encrypted_password(auth_token)  
  end

  def phoneStrip(phoneString)
    str = phoneString.gsub(/[^0-9]/, "")
    if str.length == 11
      str = str[1..str.length]
    end
    str
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :password, :phone_number) }
  end
end
