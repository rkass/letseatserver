class AddLastRequestTime < ActiveRecord::Migration
  def change
    add_column :users, :requests_changed, :datetime
  end
end
