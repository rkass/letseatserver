class Removereqs < ActiveRecord::Migration
  def change
    remove_column :users, :requests
    remove_column :users, :requests_changed
  end
end
