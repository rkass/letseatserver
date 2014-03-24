class Restaurant
  def initialize(name, price, address, types_list, url, rating_img)
    @name = name
    @price = price
    @address = address
    @types_list = types_list
    @url = url
    @rating_img = rating_img
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
  def percentMatch
    puts "Implement ME!"
    100
  end
  def distanceToLocation(loc)
    puts "Implement ME!"
    0.1
  end
  def serialize(invitation, user)
  end
end
