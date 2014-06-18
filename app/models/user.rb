class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  validates :email, :presence => false, :uniqueness => false
  validates :username, :presence => true, :uniqueness => true
  serialize :responded_to
  has_and_belongs_to_many :invitations
  def email_required?
    false
  end
  def email_changed?
    false
  end
  def invitationsPendingMyResponse
    arr = []
    for invitation in self.invitations
      arr.append(invitation) unless invitation.responded(self)
    end
    arr
  end
  def sendPush(invitation, inviteLink)
    s3 = AWS::S3.new
    obj = s3.buckets['prodpem'].objects['apple_push_notification.pem']
    fname = "tempfile.pem"
    File.open(fname, 'wb') do |fo|
      fo.print obj.read
    end
    file = File.new(fname)
    certificate = file.read
    passphrase = "ryan30"
    connection = Houston::Connection.new(Houston::APPLE_PRODUCTION_GATEWAY_URI, certificate, passphrase)
    notification = Houston::Notification.new(device: self.device_token)
    if inviteLink
      if (invitation.restaurants != nil) and (invitation.restaurants != []) and (invitation.updatingRecommendations == 0)
        notification.alert = "Your meal has been scheduled for " + invitation.restaurants.first().name + "!"
      else
        notification.alert = "Your meal has been scheduled!"
      end
      notification.custom_data = {link:"invite", num:invitation.id}
    else
      notification.alert = "You have a new invitation waiting for you!"
      notification.custom_data = {link:"invitations", scheduled:invitation.scheduled}
    end
    notification.sound = "sosumi.aiff"
    connection.open
    connection.write(notification.message)
    connection.close
    print "Sent push: " + notification.alert + " to " + self.phone_number
  end
end
