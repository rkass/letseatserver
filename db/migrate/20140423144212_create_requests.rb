class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.string :api

      t.timestamps
    end
  end
end
