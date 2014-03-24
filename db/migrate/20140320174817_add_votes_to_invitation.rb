class AddVotesToInvitation < ActiveRecord::Migration
  def change
    add_column :invitations, :votes, :text
  end
end
