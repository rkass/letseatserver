class AddRespondedToToUser < ActiveRecord::Migration
  def change
    add_column :users, :responded_to, :text
  end
end
