class AddTimeToInvitation < ActiveRecord::Migration
  def change
    add_column :invitations, :time, :datetime
  end
end
