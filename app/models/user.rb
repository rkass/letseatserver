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
end
