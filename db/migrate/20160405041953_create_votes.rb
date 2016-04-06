class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.integer :vote_product_id
      t.integer :voting_id
      t.integer :votes, default: 0

      t.timestamps null: false
    end
  end
end
