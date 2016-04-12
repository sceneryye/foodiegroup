class CreateWishlists < ActiveRecord::Migration
  def change
    create_table :wishlists do |t|
      t.boolean :online
      t.string :picture
      t.string :title
      t.decimal :price
      t.text :description
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
