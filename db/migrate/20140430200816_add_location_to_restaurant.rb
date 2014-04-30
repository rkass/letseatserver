class AddLocationToRestaurant < ActiveRecord::Migration
  def change
    add_column :restaurants, :location, :string
  end
end
