class AddCommisionToGroupbuy < ActiveRecord::Migration
  def change
    add_column :groupbuys, :commision,  precision:6, scale:2
  end
end
