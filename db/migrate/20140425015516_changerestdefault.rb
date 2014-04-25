class Changerestdefault < ActiveRecord::Migration
  def change
    change_column_default :restaurants, :votes, []
  end
end
