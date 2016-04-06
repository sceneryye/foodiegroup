class CreateVotings < ActiveRecord::Migration
  def change
    create_table :votings do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
