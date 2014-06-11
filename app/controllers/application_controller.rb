class ApplicationController < ActionController::Base
  before_filter :configure_permitted_parameters, if: :devise_controller?

  protected

  def validateUser(auth_token)
    User.find_by_auth_token(auth_token)  
  end

  def self.phoneStrip(phoneString)
    str = phoneString.gsub(/[^0-9]/, "") 
    if str.length == 11
      str = str[1..str.length]
    end 
    str 
  end

  def phoneStrip(phoneString)
    self.class.phoneStrip(phoneString)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :password, :phone_number) }
  end

  def sendInviteText(ratings, date, phoneNumber)
    date = date.strftime('%b %e, %l:%M %p')
    msg = phoneNumber + " has invited you out to eat " + " on " + date + ". " + "Click here to reply and have your say about where you eat:"
    account_sid = 'AC2f765a199ace2dc474a668b9daa59b5c' 
    auth_token = '3f3d821890f60e0a8240cab0232be4a1' 
    msg += "  immense-fortress-7865.herokuapp.com/invited" 
    # set up a client to talk to the Twilio REST API 
    @client = Twilio::REST::Client.new account_sid, auth_token 
 
    @client.account.messages.create({
      :from => '+15162520417',    
      :to => phoneNumber,
      :body => msg, 
    })
  end 

  def sendRegistrationText(auth_token, phoneNumber)
    account_sid = 'AC2f765a199ace2dc474a668b9daa59b5c'
    auth_token2 = '3f3d821890f60e0a8240cab0232be4a1'
    @client = Twilio::REST::Client.new account_sid, auth_token2
    @client.account.messages.create({
      :from => '+15162520417',
      :to => phoneNumber,
      :body => "Click this link to confirm your registration and start using Let\'s Eat! http://immense-fortress-7865.herokuapp.com/register?auth_token=#{auth_token}" 
     })
  end
end
