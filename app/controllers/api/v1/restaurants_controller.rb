class ::Api::V1::RestaurantsController < ApplicationController

  def vote
    user = User.find_by_auth_token(params[:auth_token])
    i = Invitation.find(params[:invitation])
    r = Restaurant.new(params[:name], params[:price], params[:address], params[:types], params[:url], params[:ratingImg], params[:snippetImg])
    for restaurant, vot in i.votes
      if restaurant.url == r.url
        vot.append(user.id)
        i.save
        return
      end
    end
    i.votes[r] = [user.id]
    i.save
  end

  def unvote
    user = User.find_by_auth_token(params[:auth_token])
    i = Invitation.find(params[:invitation])
    r = Restaurant.new(params[:name], params[:price], params[:address], params[:types], params[:url], params[:ratingImg], params[:snippetImg])    for restaurant, vot in i.votes
      if restaurant.url == r.url
        vot.delete(user.id) 
        i.save
        return
      end   
    end
  end 

end
