class Changefbid < ActiveRecord::Migration
  def change
    change_column :user, :facebook_id, :string
  end
end
