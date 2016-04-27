class AddColumnsToGroupbuy < ActiveRecord::Migration
  def change
    add_column :groupbuys, :set_ratio, :integer, limit: 6
    add_column :groupbuys, :single_unit, :string, limit: 20
  end
end
