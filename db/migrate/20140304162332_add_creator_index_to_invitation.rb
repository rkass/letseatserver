class AddCreatorIndexToInvitation < ActiveRecord::Migration
  def change
    add_column :invitations, :creator_index, :integer
  end
end
