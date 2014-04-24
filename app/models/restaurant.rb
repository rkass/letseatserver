class Restaurant < ActiveRecord::Base
belongs_to :invitation
serialize :types_list
serialize :votes
serialize :categories

  def userVoted(user)
    self.votes.include?user.id
  end

  def computePrice(user)
    return 1 if userVoted(user)
    prefs = self.invitation.preferencesForUser(user)
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

  def computeFoodScore
  end

  def compute
  end
    

end
