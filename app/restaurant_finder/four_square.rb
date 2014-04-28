class FourSquare

  attr_accessor :userlessClient
  @@version = '20140425'
  @@client_id = 'U2DDUHDD4UTHRFEKS1AFUBEHJOOGBILRZJM1FCNWWNIG0AKU'
  @@secret = 'XATGAZ33F3ZIC5QXVIRQCOGLVI3003CB1QB2MMKN5UPLBIAY'

  def initialize
    @userlessClient = Foursquare2::Client.new(:client_id => @@client_id, :client_secret => @@secret, :api_version => @@version)
    self
  end

end
