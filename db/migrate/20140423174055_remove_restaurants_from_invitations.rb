class RemoveRestaurantsFromInvitations < ActiveRecord::Migration
  def change
    remove_column :invitations, :restaurants, :text
  end
end
