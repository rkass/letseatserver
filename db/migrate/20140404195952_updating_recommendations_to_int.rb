class UpdatingRecommendationsToInt < ActiveRecord::Migration
  def change
    remove_column :invitations, :updatingRecommendations, :boolean
    add_column :invitations, :updatingRecommendations, :integer, :default => 0
  end
end
