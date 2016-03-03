class AddGoodsSizeAndGoodsBbdToGroupbuy < ActiveRecord::Migration
  def change
    add_column :groupbuys, :goods_size, :string
    add_column :groupbuys, :goods_bbd, :date
  end
end
