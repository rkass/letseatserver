class AddVotesToInvitation < ActiveRecord::Migration
  def change
    add_column :invitations, :responses, :text
  end
end
