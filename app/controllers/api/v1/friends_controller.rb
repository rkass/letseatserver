class Api::V1::FriendsController < ApplicationController

  def get
    user = validateUser(params[:auth_token])
    if user == nil
      render :json => {:error=>"Bad Login"}, :status=>422
      return
    end
    ret = {}
    contacts = params[:contacts]
    for contact in contacts
      numbers = []
      for contactPhone in contact[:phone_numbers]
        number = phoneStrip(contactPhone)
        users = User.find_all_by_phone_number(number)
        if users != nil and users.length > 0
          for u in users
            if u.encrypted_password != params[:auth_token]
              numbers.push(number)
              break
            end
          end
        end
      end
      if numbers.length > 0
        name = ""
        if contact[:first_name] != nil
          name += contact[:first_name]
        end
        if contact[:last_name] != nil
          name += " " + contact[:last_name]
        end
        ret[name] =numbers
      end
    end
    render :json => {:success => "True", :length => ret.length, :friends => ret}
    return
  end

end
