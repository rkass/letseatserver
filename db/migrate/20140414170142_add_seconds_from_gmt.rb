class AddSecondsFromGmt < ActiveRecord::Migration
  def change
    add_column :invitations, :seconds_from_gmt, :integer
  end
end
