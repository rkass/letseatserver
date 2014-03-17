class Api::V1::FriendsController < ApplicationController

  def get(negative)
    user = validateUser(params[:auth_token])
    if user == nil
      render :json => {:error=>"Bad Login"}, :status=>422
      return
    end
    ret = {}
    for contact in params[:contacts]
      numbers = []
      if contact[:phone_numbers] != nil
        for contactPhone in contact[:phone_numbers]
          number = phoneStrip(contactPhone)
          users = User.find_all_by_phone_number(number)
          if ((users != nil and users.length) == negative)
            puts "in here"
            for u in users
              if u.encrypted_password != params[:auth_token]
                puts "in there"
                numbers.push(number)
                break
              end
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

  def getFriends
    get(true)
  end

  def getNonFriends
    get(false)
  end

end
