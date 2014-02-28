class AddResponsesToInvitation < ActiveRecord::Migration
  def change
    add_column :invitations, :responses, :text, array: true, default: '{}'
  end
end
