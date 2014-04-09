class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.text :preferences
      t.text :voted_restaurant
      t.text :other_restaurants

      t.timestamps
    end
  end
end
