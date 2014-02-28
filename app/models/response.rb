class Response < Preferences
  def initialize(going, message, types_list, location)
    @going = going
    @message = message
    @types_list = types_list
    @location = location
  end
  def going
    @going
  end
  def message
    @message
  end
end
