class Addnewpreferencestoinvitation < ActiveRecord::Migration
  def change
    add_column :invitations, :new_preferences, :text
  end
end
