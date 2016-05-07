class AddColumnsToGroupbuy < ActiveRecord::Migration
  def change
    add_column :groupbuys, :set_ratio,  precision:6, scale:2
  end
end
