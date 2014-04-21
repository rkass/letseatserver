class AddInviteesToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :invitees, :text
  end
end
