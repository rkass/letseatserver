class AddScheduleTime < ActiveRecord::Migration
  def change
    add_column :invitations, :scheduleTime, :datetime
    add_column :invitations, :central, :boolean
    add_column :invitations, :scheduled, :boolean
  end
end

