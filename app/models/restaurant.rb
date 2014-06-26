class Restaurant < ActiveRecord::Base
belongs_to :invitation
serialize :types_list
serialize :votes
serialize :categories

  def userVoted(user)
    self.votes.include?user.id
  end

  def compute(foodWeight, priceWeight, distanceWeight, restWeight)
    computeTotalFoodScore
    computeTotalPriceScore
    computeDistanceScore  
    computeRestScore
    computePercentMatch(foodWeight, priceWeight, distanceWeight, restWeight)
    self.save
  end 
  
  def recalculateDistance
    puts "RECALCING DISTANCE"
    self.location = RestaurantFinder.getCoordinates(self.address)
    inviation_arr = [self.invitation.location.split(',')[0].to_f, self.invitation.location.split(',')[1].to_f]
    loc_arr = [self.location.split(',')[0].to_f, self.location.split(',')[1].to_f]
    self.distance = RestaurantFinder.distance(loc_arr, invitation_arr)
    self.save
  end

  def computePercentMatch(foodWeight, priceWeight, distanceWeight, restWeight)
    self.percent_match = [percentVoted, (foodWeight * self.sum_food_scores + priceWeight * self.sum_price_scores + distanceWeight * self.distance_score + restWeight * self.rating_score) / (foodWeight + priceWeight + distanceWeight + restWeight)].max
  end

  def computePriceScore(user)
    return 1 if userVoted(user)
    prefs = self.invitation.preferencesForUser(user)
    return 0 if prefs == nil
    if self.price == 1
      min = 7
      max = 12
    elsif self.price == 2
      min = 13
      max = 19
    elsif self.price == 3
      min = 20
      max = 49
    elsif self.price == 4
      min = 50
      max = 70
    end
    return 1 if (prefs.minPrice <= min) or (prefs.maxPrice >= max)
    return 0
  end

  def getLECategories
    self.categories.map{ |c| RestaurantFinder.getLECategory(c[1]) }
  end

  def computeFoodScore(user)
    return self.invitation.responses.length + 1 if userVoted(user)
    prefs = self.invitation.preferencesForUser(user)
    return 0 if prefs == nil
    score = 0
    for category in self.categories 
      score = self.invitation.responses.length + 1 - 1 if prefs.ratings_dict[category[1]] == 1
      return self.invitation.responses.length + 1 if prefs.ratings_dict[category[1]] == 2
    end
    return score
  end

  def computeDistanceScore
    if self.distance == nil
      self.distance_score = 0
    else
      self.distance_score = [(1 - (self.distance / 40000))**2,0].max
    end
  end 
  
  def computeTotalFoodScore
    tot = 0.0
    for u in self.invitation.users
      tot += computeFoodScore(u)
    end
    self.sum_food_scores = tot / (self.invitation.responses.select{|r| r != nil}.length * (self.invitation.responses.length + 1))
  end

  def computeTotalPriceScore
    tot = 0.0
    for u in self.invitation.users
      tot += computePriceScore(u)
    end
    self.sum_price_scores = tot / (self.invitation.responses.length - self.invitation.responses.count(nil))
  end

  def serialize(user)
    ret = self.attributes
    ret['user_voted'] = self.votes.include?user.id
    ret['votes'] = self.votes.length
    if self.percent_match == nil
      ret['percent_match'] = 0
    else
      ret['percent_match'] = (self.percent_match*100).round / 100.0
    end
    ret
  end

  def percentVoted
    votes = 0.0
    for u in self.invitation.users
      votes += 1 if userVoted(u)
    end
    return votes / (self.invitation.responses.length - self.invitation.responses.count(nil))
  end

  def computeRestScore
    if self.review_count > 100
      self.rating_score = 1 if self.rating == 5
      self.rating_score = 0.97 if self.rating == 4.5
      self.rating_score = 0.95 if self.rating == 4
      self.rating_score = 0.9 if self.rating == 3.5
      self.rating_score = 0.85 if self.rating == 3
      self.rating_score = 0.5 if self.rating == 2.5
      self.rating_score = 0.25 if self.rating == 2
      self.rating_score = 0.1 if self.rating == 1.5
      self.rating_score = 0.05 if self.rating == 1
      self.rating_score = 0.02 if self.rating == 0.5
      self.rating_score = 0 if self.rating == 0
    elsif self.review_count > 50
      self.rating_score = 0.97 if self.rating == 5
      self.rating_score = 0.95 if self.rating == 4.5 
      self.rating_score = 0.9 if self.rating == 4
      self.rating_score = 0.85 if self.rating == 3.5 
      self.rating_score = 0.8 if self.rating == 3
      self.rating_score = 0.5 if self.rating == 2.5 
      self.rating_score = 0.3 if self.rating == 2
      self.rating_score = 0.2 if self.rating == 1.5 
      self.rating_score = 0.1 if self.rating == 1
      self.rating_score = 0.05 if self.rating == 0.5
      self.rating_score = 0.02 if self.rating == 0
    elsif self.review_count > 10
      self.rating_score = 0.95 if self.rating == 5
      self.rating_score = 0.92 if self.rating == 4.5 
      self.rating_score = 0.87 if self.rating == 4
      self.rating_score = 0.82 if self.rating == 3.5 
      self.rating_score = 0.77 if self.rating == 3
      self.rating_score = 0.5 if self.rating == 2.5 
      self.rating_score = 0.31 if self.rating == 2
      self.rating_score = 0.25 if self.rating == 1.5 
      self.rating_score = 0.1 if self.rating == 1
      self.rating_score = 0.05 if self.rating == 0.5
      self.rating_score = 0.03 if self.rating == 0
    else
      self.rating_score = 0.7 if self.rating == 5
      self.rating_score = 0.65 if self.rating == 4.5 
      self.rating_score = 0.6 if self.rating == 4
      self.rating_score = 0.55 if self.rating == 3.5 
      self.rating_score = 0.52 if self.rating == 3
      self.rating_score = 0.5 if self.rating == 2.5 
      self.rating_score = 0.48 if self.rating == 2
      self.rating_score = 0.45 if self.rating == 1.5 
      self.rating_score = 0.38 if self.rating == 1
      self.rating_score = 0.32 if self.rating == 0.5
      self.rating_score = 0.25 if self.rating == 0
    end
  end
    

end
