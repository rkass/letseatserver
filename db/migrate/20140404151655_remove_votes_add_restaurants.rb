class RemoveVotesAddRestaurants < ActiveRecord::Migration
  def change
    remove_column :invitations, :votes, :text
    add_column :invitations, :restaurants, :text
  end
end
