class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.integer :user_id
      t.integer :comment_id
      t.integer :event_id
      t.integer :topic_id
      t.integer :status

      t.timestamps null: false
    end
  end
end
