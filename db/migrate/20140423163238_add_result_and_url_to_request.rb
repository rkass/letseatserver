class AddResultAndUrlToRequest < ActiveRecord::Migration
  def change
    add_column :requests, :url, :text
    add_column :requests, :result, :text
  end
end
