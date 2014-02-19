class AllowNullEmail < ActiveRecord::Migration
  def up
    remove_index :users, :email
    change_column :users, :email, :string, :null => true
  end

  def down
    change_column :users, :email, :string, :null => false
    add_index :users, :email, unique: true
  end
end
