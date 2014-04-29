require 'open-uri'
require 'ostruct'
require 'similar_text'

class MyGooglePlaces


  
@@api_key = 'AIzaSyBITjgfUC0tbWp9-0SRIRR-PYAultPKDbA'

  def self.isOpenAndPrice(formattedAddress, dayOfWeek, time, client)
    refStruct = self.getReference(formattedAddress, client)
    returnStruct = self.isOpenAndPriceHelper(refStruct.ref, dayOfWeek, time, client)
    returnStruct.requests = [returnStruct.request, refStruct.request]
    return returnStruct
  end

  def self.api_key
    @@api_key
  end

  #location like "40.72918605727255,-73.9608789"
  #name like "Russo Mozzarella & Pasta"
  def self.getReference(formattedAddress, client)
    retStruct = OpenStruct.new
    query = CGI::escape(formattedAddress)
    str = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=#{query}&sensor=false&key=#{@@api_key}"
    
    result = client.search({:query => query})
    response = result
    retStruct.request = {:api => 'google', :result => result, :url => str}
    return retStruct if (response == nil or response.results == nil or response.results[0] == nil)
    sim = self.getSim(formattedAddress, response.results[0])
    ref = response.results[0].reference
    cnt = 0
    scnt = 0
    for biz in response.results[1..-1]
      thisSim = getSim(formattedAddress, biz)
      if (thisSim > sim)
        sim = thisSim
        ref = biz.reference
        scnt = cnt
      end
      cnt += 1
    end
    retStruct.ref = ref
    return retStruct
  end

  def self.getSim(formattedAddress, results)
    formattedAddress.similar(results.name + ", " + results.formatted_address)
  end

  #time like "2000" for 8pm and "0930" for 9:30 am
  #dayOfWeek like 0 for sunday and 2 for tuesday
  def self.isOpenAndPriceHelper(ref, dayOfWeek, time, client)
    return OpenStruct.new if ref == nil
    str = "https://maps.googleapis.com/maps/api/place/details/json?reference=#{ref}&sensor=false&key=#{@@api_key}"
    ret = OpenStruct.new
    result = client.details(ref)
    ret.request = {:api => 'google', :result => result, :url => str}
    deets = result
    if deets == nil or deets.result == nil
      return ret
    end
    ret.price = deets.result.price_level
    open = close = nil
    if deets.result.opening_hours  == nil
      return ret
    end
    for period in deets.result.opening_hours.periods
      if period.close != nil and period.close.day == dayOfWeek
        open_end = period.close.time.to_i
      end
      if period.close != nil and period.open.day == dayOfWeek
        open_start = period.open.time.to_i
      end
    end
    if open_start == nil or open_end == nil
      ret.open = nil
    else
      ret.open = (time.to_i >= open_start and time.to_i <= open_end)
    end
    ret.open_start = open_start
    ret.open_end = open_end
    return ret
  end

end
