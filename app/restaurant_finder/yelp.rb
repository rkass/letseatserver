require 'oauth'
require 'open-uri'

class Yelp
  @@consumer_key = 'O2jADZ7MqvooLsdtko4lyA'
  @@consumer_secret = 'y7aXx_LgE46hoBw9xP78tQLE1FU'
  @@token = 'CFScV3ZelPlNU-aXJvdEjSKAYUDv9Ntg'
  @@token_secret = 'kVb6qOneXT2GoUuhVmzr-rAH8JY'

  #location like "40.727676,-73.984593"
  #category like "pizza" 
  def self.getResults(location, category, radius)
    category = category.downcase
    #results stored in json result in businesses index
    consumer = OAuth::Consumer.new(@@consumer_key, @@consumer_secret, {:site => "http://api.yelp.com", :signature_method => "HMAC-SHA1", :scheme => :query_string})
    access_token = OAuth::AccessToken.new(consumer, @@token, @@token_secret)
    url = URI::encode("/v2/search?ll=#{location}&category_filter=#{category}&radius_filter=#{radius}")
    result = access_token.get(url).body
    Request.create({:api => 'yelp', :url => url, :result => result})
    return JSON.parse(result)['businesses']
  end

  def self.getAssociatedCategories
  end

end
