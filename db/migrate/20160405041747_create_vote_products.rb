class CreateVoteProducts < ActiveRecord::Migration
  def change
    create_table :vote_products do |t|
      t.string :picture
      t.string :title

      t.timestamps null: false
    end
  end
end
