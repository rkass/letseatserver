class Restaurant
  def initialize(name, price, address, types_list, url, rating_img, snippet_img)
    @name = name
    @price = price
    @address = address
    @types_list = types_list
    @url = url
    @rating_img = rating_img
    @snippet_img = snippet_img
  end 
  def name
    @name
  end 
  def price
    @price
  end
  def address
    @address
  end
  def types_list
    @types_list
  end
  def url
    @url
  end
  def rating_img
    @rating_img
  end
  def snippet_img
    @snippet_img
  end
  def percentMatch(invitation)
    100
  end
  def distanceToLocation(loc)
    0.1
  end
  def serialize(invitation, user)
    ret = {}
    ret['percentMatch'] = self.percentMatch(invitation)
    ret['name'] = self.name
    ret['price'] = self.price
    ret['address'] = self.address
    ret['types_list'] = self.types_list
    ret['url'] = self.url
    ret['rating_img'] = self.rating_img
    ret['snippet_img'] = self.snippet_img
    ret['distance'] = self.distanceToLocation(invitation.location)
    ivotes = invitation.votes
    votes = []
    ivotes = {} if ivotes == nil
    for k, v in ivotes
      if k.url == self.url
        votes = v
        break
      end
    end
    ret['votes'] = votes.length
    ret['user_voted'] = votes.include?user.id
    ret
  end
end
