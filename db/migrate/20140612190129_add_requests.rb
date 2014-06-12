class AddRequests < ActiveRecord::Migration
  def change
    add_column :users, :requests, :integer
  end
end
