require 'open-uri'
require 'ostruct'
require 'similar_text'

class GooglePlaces

  @@api_key = 'AIzaSyBITjgfUC0tbWp9-0SRIRR-PYAultPKDbA'

  def self.isOpenAndPrice(formattedAddress, dayOfWeek, time)
    return self.isOpenAndPriceHelper(self.getReference(formattedAddress), dayOfWeek, time)
  end

  #location like "40.72918605727255,-73.9608789"
  #name like "Russo Mozzarella & Pasta"
  def self.getReference(formattedAddress)
    query = CGI::escape(formattedAddress)
    str = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=#{query}&sensor=false&key=#{@@api_key}"
    response = JSON.parse(open(str).read)
    sim = getSim(formattedAddress, response['results'][0])
    ref = response['results'][0]['reference']
    cnt = 0
    scnt = 0
    for biz in response['results'][1..-1]
      thisSim = getSim(formattedAddress, biz)
      if (thisSim < sim)
        sim = thisSim
        ref = biz['reference']
        scnt = cnt
      end
      cnt += 1
    end
    puts "formatted address"
    puts formattedAddress
    puts "selected business"
    puts response['results'][scnt]
    return ref if ref != nil
    puts "reference is nil for"
    puts formattedAddress
  end

  def getSim(formattedAddress, results)
    formattedAddress.similar(results['name'] + ", " + results['formatted_address'])
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
    if deets['result']['opening_hours'] == nil
      puts "Opening hours nil"
      puts "deets:"
      puts deets
      puts "str:"
      puts str
      return ret
    end
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
