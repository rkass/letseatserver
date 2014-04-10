require 'oauth'
require 'open-uri'

class Yelp
  @@consumer_key = 'O2jADZ7MqvooLsdtko4lyA'
  @@consumer_secret = 'y7aXx_LgE46hoBw9xP78tQLE1FU'
  @@token = 'CFScV3ZelPlNU-aXJvdEjSKAYUDv9Ntg'
  @@token_secret = 'kVb6qOneXT2GoUuhVmzr-rAH8JY'

  #location like "40.727676,-73.984593"
  #category like "pizza" 
  def self.getResults(location, category, limit)
    category = category.downcase
    #results stored in json result in businesses index
    consumer = OAuth::Consumer.new(@@consumer_key, @@consumer_secret, {:site => "http://api.yelp.com", :signature_method => "HMAC-SHA1", :scheme => :query_string})
    access_token = OAuth::AccessToken.new(consumer, @@token, @@token_secret)
    return JSON.parse(access_token.get(URI::encode("/v2/search?ll=#{location}&category_filter=#{category}&limit=#{limit}")).body)['businesses']
  end

  def self.getAssociatedCategories

end
