class Request < ActiveRecord::Base
serialize :result

  def referenceNumber
    self.url[self.url.index('=') + 1..self.url.index('&') - 1]
  end

  def query
    self.url[self.url.index('query=') + 6..self.url.index('&sensor') -1]
  end

  def jsonResult
    JSON.parse(result)
  end

  def makeRequest(client)
    if self.url.include?"detail"
      client.spot(self.referenceNumber)
    else
      client.spots_by_query(self.query)
    end
  end

end
