class AddGroupbuyPriceToGroupbuy < ActiveRecord::Migration
  def change
    add_column :groupbuys, :groupbuy_price, :decimal, precision: 10, scale: 2
  end
end
