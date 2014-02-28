class Losecreatorprefs < ActiveRecord::Migration
  def change
    remove_column :invitations, :creator_preferences, :text
  end
end
