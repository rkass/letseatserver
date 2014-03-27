class AddMinimumAttendingToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :minimum_attending, :integer
  end
end
