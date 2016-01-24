class AddWeightToGroupbuys < ActiveRecord::Migration
  def change
    add_column :groupbuys, :weight, :decimal, precision:10, scale:2
  end
end
