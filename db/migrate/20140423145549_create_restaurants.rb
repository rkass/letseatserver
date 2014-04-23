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
      t.float :rating
      t.string :categories
      t.integer :review_count
      t.string :open_start
      t.string :open_end
      t.boolean :open
      t.float :sum_price_scores
      t.float :sum_food_scores
      t.float :distance
      t.float :distance_score
      t.text :votes
      t.float :rating_score
      t.float :percent_match

      t.timestamps
    end
  end
end
