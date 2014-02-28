class Createhasandbelong2 < ActiveRecord::Migration
  def change
    drop_table :users_invitations
    create_table :invitations_users do |t|
      t.belongs_to :invitation
      t.belongs_to :user
    end
  end
end
