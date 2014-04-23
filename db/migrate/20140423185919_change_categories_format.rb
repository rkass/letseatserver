class ChangeCategoriesFormat < ActiveRecord::Migration
  def change
    change_column :restaurants, :categories, :text  
  end
end
