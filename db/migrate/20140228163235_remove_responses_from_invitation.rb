class RemoveResponsesFromInvitation < ActiveRecord::Migration
  def change
    remove_column :invitations, :responses, :text
    add_column :invitations, :responses, :text
    add_column :invitations, :creator_preferences, :text
  end
end
