class Changefailsafe < ActiveRecord::Migration
  def change
     change_column :users, :fail_safe, :string 
  end
end
