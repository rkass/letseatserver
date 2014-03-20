require Rails.root.join('app', 'models', 'preferences.rb').to_s
require Rails.root.join('app', 'models', 'response.rb').to_s

class Invitation < ActiveRecord::Base
  serialize :responses
  validate :validator
  has_and_belongs_to_many :users, :order => :id
  def self.customNew(users, time, scheduleTime, central, message = nil)
    i = Invitation.new
    i.users = users
    i.responses = ([nil] * (users.length))
    i.time = time
    i.scheduleTime = scheduleTime
    i.central = central
    i.scheduled = false
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
   self.creator_index = self.users.index(user) if creator
   self.responses[self.users.index(user)] = preferences
   self.save 
  end
  def respondNo(arguser, message)
    responses = self.responses
    responses[self.users.index(arguser)] = Response.new(false, message, nil, nil, nil)
    self.responses = responses
    self.save
  end
  def respondYes(arguser, response)
    responses = self.responses
    responses[self.users.index(arguser)] = response
    self.responses = responses
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
      if count == self.creator_index
        ret["responses"].append("yes")
      elsif self.responses[count] == nil
        ret["responses"].append("undecided")
      elsif self.responses[count].going
        ret["responses"].append("yes")
      else
        ret["responses"].append("no")
      end
      count += 1
    end
    ret["preferences"] = []
    for response in self.responses
      if response == nil
        ret["preferences"].append([]) 
      else
        ret["preferences"].append(response.types_list)
      end
    end
    ret["time"] = self.time.to_formatted_s(:rfc822)
    index = ret["time"].index("+")
    index = ret["time"].index("-") if index == nil
    ret["time"] = ret["time"][0..index - 2]
    ret["message"] = self.message
    ret["id"] = self.id
    ret["iResponded"] = self.responded(arguser)
    ret["creatorIndex"] = self.creator_index
    ret["central"] = self.central
    ret
  end
end
