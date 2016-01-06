class AddMarketPriceToGroupbuy < ActiveRecord::Migration
  def change
    add_column :groupbuys, :market_price, :decimal, precision: 10, scale: 2
  end
end
