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

  def sendInviteText(typesList, date, phoneNumber)
    date = date.strftime('%b %e, %l:%M %p')
    typesString = ""
    typesString = typesList[0] + " food" if typesList.length == 1
    if typesList.length > 1
      cnt = 0
      while (cnt < (typesList.length - 1))
        typesString += typesList[cnt] + ", "
        cnt += 1
      end
      typesString += "or " + typesList[cnt] + " food"
    end
    msg = phoneNumber + " has invited you to go out for " + typesString + " on " + date + ". " + "Click here to respond by downloading Let's Eat." if typesList.length > 0
    msg = phoneNumber + " has invited you out to eat " + " on " + date + ". " + "Click here to respond by downloading Let's Eat." if typesList.length == 0
    account_sid = 'AC2f765a199ace2dc474a668b9daa59b5c' 
    auth_token = '3f3d821890f60e0a8240cab0232be4a1' 
 
    # set up a client to talk to the Twilio REST API 
    @client = Twilio::REST::Client.new account_sid, auth_token 
 
    @client.account.messages.create({
      :from => '+15162520417',    
      :body => msg, 
      :media_url => 'http://google.com',
    })
  end  

end
