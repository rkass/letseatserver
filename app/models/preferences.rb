class Preferences
  def initialize(types_list, location, price)
    @types_list = types_list
    @location = location
    @price = price
  end
  def types_list
    @types_list
  end
  def location
    @location
  end
  def price
    @price
  end
end
