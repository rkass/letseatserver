require Rails.root.join('app', 'models', 'preferences.rb').to_s

class Invitation < ActiveRecord::Base
  serialize :responses
  validate :validator
  has_and_belongs_to_many :users
  def self.customNew(users, time, message = nil)
    i = Invitation.new
    i.users = users
    i.responses = ([nil] * (users.length))
    i.time = time
    i.message = message
    i
  end
  def validator
    errors.add(:users, "Supply a creator") if self.users.length < 1
    errors.add(:responses, "Provide a response for all invitees and initialize it to nil") if (self.responses.length != self.users.length)
    errors.add(:time, "Provide a time for the invite") if (self.time == nil)
  end
  def responded(arguser)
    self.responses[self.users.index(arguser)] != nil
  end
  def insertPreferences(user, preferences, creator = false)
   self.creator_index = self.users.index if creator
   self.responses[self.users.index(user)] = preferences
   self.save 
  end
  def serialize(arguser)
    ret = {}
    ret["people"] = []
    for user in self.users
      ret["people"].append(user.phone_number)
    end
    ret["responses"] = []
    count = 0
    for response in self.responses
      if count == self.users.index(arguser)
        ret["responses"].append(true)
      elsif self.responses[count] == nil
        ret["responses"].append(nil)
      else
        ret["responses"].append(self.responses[count].going)
      end
      count += 1
    end
    ret["time"] = self.time.to_formatted_s(:rfc822)
    index = ret["time"].index("+")
    index = ret["time"].index("-") if index == nil
    ret["time"] = ret["time"][0..index - 2]
    ret["message"] = self.message
    ret["id"] = self.id
    ret["iResponded"] = self.responded(arguser)
    ret["creatorIndex"] = self.creator_index
    ret
  end
end
