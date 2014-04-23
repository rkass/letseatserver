class Addrestassoc < ActiveRecord::Migration
  def change
    change_table :restaurants do |t|
      t.references :invitation
    end
  end
end
