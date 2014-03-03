require Rails.root.join('app', 'models', 'preferences.rb').to_s

class Invitation < ActiveRecord::Base
  serialize :responses
  validate :validator
  has_and_belongs_to_many :users
  def self.customNew(users, creatorPreferences, time, message = nil)
    i = Invitation.new
    i.users = users
    if creatorPreferences.kind_of?(Array)
      i.responses = creatorPreferences
    else
      i.responses = [creatorPreferences] + ([nil] * (users.length - 1))
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
    self.responses[self.users.index(user)] != nil
  end
  def serialize
    ret = {}
    ret["people"] = []
    for user in self.users
      ret["people"].append(user.phone_number)
    end
    ret["time"] = self.time.to_formatted_s(:rfc822)
    ret["message"] = self.message
  end
end
