class CreateDownpayments < ActiveRecord::Migration
  def change
    create_table :downpayments do |t|
      t.integer :user_id
      t.integer :wishlist_id
      t.float :price

      t.timestamps null: false
    end
  end
end
