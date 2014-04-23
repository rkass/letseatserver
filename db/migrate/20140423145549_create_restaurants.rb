class CreateRestaurants < ActiveRecord::Migration
  def change
    create_table :restaurants do |t|
      t.string :name
      t.integer :price
      t.string :address
      t.text :types_list
      t.string :url
      t.string :rating_img
      t.string :snippet_img
      t.double :rating
      t.string :categories
      t.integer :review_count
      t.string :open_start
      t.string :open_end
      t.boolean :open
      t.double :sum_price_scores
      t.double :sum_food_scores
      t.double :distance
      t.double :distance_score
      t.text :votes
      t.double :rating_score
      t.double :percent_match

      t.timestamps
    end
  end
end
