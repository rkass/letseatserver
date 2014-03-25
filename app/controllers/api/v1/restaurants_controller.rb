class ::Api::V1::RestaurantsController < ApplicationController

  def vote
    user = User.find_by_auth_token(params[:auth_token])
    i = Invitation.find(params[:invitation])
    r = Restaurant.new(params[:name], params[:price], params[:address], params[:types], params[:url], params[:ratingImg], params[:snippetImg])
    i.votes = {} if i.votes == nil
    retVotes = []
    skip = true
    for restaurant, vot in i.votes
      if restaurant.url == r.url
        vot.append(user.id) if (not vot.include?user.id)
        i.save
        skip = false
        retVotes = vot
        break
      end
    end
    if skip
      i.votes[r] = [user.id]
      i.save
      retVotes = [user.id]
    end
    render :json => {:success => true, :restaurant => {:user_voted => true, :votes => retVotes.length}}, :status => 201 
    return
  end

  def unvote
    user = User.find_by_auth_token(params[:auth_token])
    i = Invitation.find(params[:invitation])
    r = Restaurant.new(params[:name], params[:price], params[:address], params[:types], params[:url], params[:ratingImg], params[:snippetImg])
    retVotes = []
    for restaurant, vot in i.votes
      if restaurant.url == r.url
        vot.delete(user.id) 
        i.save
        retVotes = vot
      end   
    end
    render :json => {:success => true, :restaurant => {:user_voted => true, :votes => retVotes.length}}, :status => 201 
    return
  end 

end
