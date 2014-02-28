class Createhasandbelong < ActiveRecord::Migration
  def change
    create_table :users_invitations do |t|
      t.belongs_to :user
      t.belongs_to :invitation
    end
  end
end
