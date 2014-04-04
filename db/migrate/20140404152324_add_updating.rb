class AddUpdating < ActiveRecord::Migration
  def change
    add_column :invitations, :updatingRecommendations, :boolean, default: true
  end
end
