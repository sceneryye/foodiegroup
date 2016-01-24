class CreateLogisticsItems < ActiveRecord::Migration
  def change
    create_table :logistics_items do |t|
      t.references :logistic,  index: true
      t.string :areas
      t.integer :price
      t.integer :each_add

      t.timestamps
    end
  end
end
