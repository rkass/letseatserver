class ChangeUpdateDefault < ActiveRecord::Migration
  def change
    change_column_default(:invitations, :updatingRecommendations, false)
  end
end
