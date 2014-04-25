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
  end

  def computePercentMatch(foodWeight, priceWeight, distanceWeight, restWeight)
    self.percent_match = (foodWeight * self.sum_food_scores + priceWeight * self.sum_price_scores + distanceWeight * self.distance_score + restWeight * self.rating_score) / (foodWeight + priceWeight + distanceWeight + restWeight)
  end

  def computePriceScore(user)
    return 1 if userVoted(user)
    prefs = self.invitation.preferencesForUser(user)
    return 0 if prefs == nil
    if self.price == 1
      min = 7
      max = 14
    elsif self.price == 2
      min = 15
      max = 25
    elsif self.price == 3
      min = 26
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
    self.rating_score = ((5 * self.invitation.responses.length - 4) + 5) if userVoted(user)
    prefs = self.invitation.preferencesForUser(user)
    return 0 if prefs == nil
    cnt = 0
    while (cnt < prefs.types_list.length)
      return ((5 * (self.invitation.responses.length - 4)) + (5 - cnt)) if self.getLECategories.include?prefs.types_list[cnt].downcase
      cnt += 1
    end
    return 0
  end
  
  def computeTotalFoodScore
    tot = 0.0
    for u in self.invitation.users
      tot += computeFoodScore(u)
      puts tot
    end
    self.sum_food_scores = tot / (((5 * self.invitation.responses.length - 4) + 5) * (self.invitation.responses.length - self.invitation.responses.count(nil)))
  end

  def computeTotalPriceScore
    tot = 0.0
    for u in self.invitation.users
      tot += computePriceScore(u)
    end
    self.sum_price_scores = tot / (self.invitation.responses.length - self.invitation.responses.count(nil))
  end

  def computeDistanceScore
    self.distance_score = [1 - (self.distance / 40000),0].max
  end

  def serialize(user)
    ret = self.attributes
    ret['user_voted'] = self.votes.include?user.id
    ret
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
