class ModifyColumnsToEvent < ActiveRecord::Migration
  def change
    change_table(:events) do |t|
      t.remove :x_coordinate, :y_coordinate
      t.string :x_coordinate
      t.string :y_coordinate
    end
  end
end
