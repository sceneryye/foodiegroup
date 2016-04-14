class AddDownPaymentToWishlist < ActiveRecord::Migration
  def change
    add_column :wishlists, :down_payment, :float
  end
end
