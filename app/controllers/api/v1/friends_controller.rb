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
          puts "914 number: " + number if number.include?"914"
          users = User.find_all_by_phone_number(number)
          if ((users != nil and (users.length > 0)) == negative)
            if negative
              for u in users
                puts "number: " + number
                if u.auth_token != params[:auth_token]
                  numbers.push(number)
                  break
                end
              end
            else
              numbers.push(number)
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
