require Rails.root.join('app', 'models', 'preferences.rb').to_s

class Invitation < ActiveRecord::Base
  serialize :responses
  validate :validator
  has_and_belongs_to_many :users
  def self.customNew(users, time, message = nil)
    i = Invitation.new
    i.users = users
    i.responses = ([nil] * (users.length))
    end
    i.time = time
    i.message = message
    i
  end
  def validator
    errors.add(:users, "Supply a creator") if self.users.length < 1
    errors.add(:responses, "Provide a response for all invitees and initialize it to nil") if (self.responses.length != self.users.length)
    errors.add(:time, "Provide a time for the invite") if (self.time == nil)
  end
  def creator
    self.users[0]
  end
  def responded(user)
    puts "id"
    puts self.id
    puts "index"
    puts self.users.index(user)
    self.responses[self.users.index(user)] != nil
  end
  def insertPreferences(user, preferences)
   self.responses[self.users.index(user)] = preferences
   self.save 
  def serialize(user)
    ret = {}
    ret["people"] = []
    for user in self.users
      ret["people"].append(user.phone_number)
    end
    ret["time"] = self.time.to_formatted_s(:rfc822)
    index = ret["time"].index("+")
    index = ret["time"].index("-") if index == nil
    ret["time"] = ret["time"][0..index - 2]
    ret["message"] = self.message
    ret["id"] = self.id
    ret["iResponded"] = self.responded(user)
    ret
  end
end
