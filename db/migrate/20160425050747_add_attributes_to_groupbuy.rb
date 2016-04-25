class AddAttributesToGroupbuy < ActiveRecord::Migration
  def change
    add_column :groupbuys, :tag, :integer, limit: 2
    add_column :groupbuys, :target, :integer, limit: 5
    add_column :groupbuys, :origin, :string, limit: 20
  end
end
