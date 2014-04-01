require 'open-uri'
require 'ostruct'

class GooglePlaces

  @@api_key = 'AIzaSyBITjgfUC0tbWp9-0SRIRR-PYAultPKDbA'

  def self.isOpenAndPrice(location, name, dayOfWeek, time)
    return self.isOpenAndPriceHelper(self.getReference(location, name), dayOfWeek, time)
  end

  #location like "40.72918605727255,-73.9608789"
  #name like "Russo Mozzarella & Pasta"
  def self.getReference(location, name)
    query = CGI::escape(name + " near " + location)
    str = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=#{query}&sensor=false&key=#{@@api_key}"
    response = JSON.parse(open(str).read)
    for biz in response['results']
     return biz['reference'] if biz['name'] == name
    end
    return response['results'][0]['reference'] if (response['results']!= nil and response['results'].length > 0)
    puts "reference is nil for"
    puts name
    puts str
  end

  #time like "2000" for 8pm and "0930" for 9:30 am
  #dayOfWeek like 0 for sunday and 2 for tuesday
  def self.isOpenAndPriceHelper(ref, dayOfWeek, time)
    return OpenStruct.new if ref == nil
    str = "https://maps.googleapis.com/maps/api/place/details/json?reference=#{ref}&sensor=false&key=#{@@api_key}"
    deets = JSON.parse(open(str).read)
    ret = OpenStruct.new
    if deets == nil
      puts "Deets was nil"
      puts str
      return ret
    end
    ret.price = deets['result']['price_level']
    open = close = nil
    for period in deets['result']['opening_hours']['periods']
      if period['close']['day'] == dayOfWeek
        close = period['close']['time'].to_i
      end
      if period['open']['day'] == dayOfWeek
        open = period['open']['time'].to_i
      end
    end
    if open == nil or close == nil
      ret.open = nil
    else
      ret.open = (time.to_i >= open and time.to_i <= close)
    end
    return ret
  end

end
