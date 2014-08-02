class AddFailSafeToUser < ActiveRecord::Migration
  def change
    add_column :users, :fail_safe, :integer
  end
end
