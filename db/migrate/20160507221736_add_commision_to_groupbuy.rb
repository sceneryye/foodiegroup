class AddCommisionToGroupbuy < ActiveRecord::Migration
  def change
    add_column :groupbuys, :commision, :decimal, precision:6, scale:2
  end
end
