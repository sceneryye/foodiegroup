class CreateJoinTableUserVoting < ActiveRecord::Migration
  def change
    create_join_table :users, :votings do |t|
       t.index [:user_id, :voting_id]
       t.index [:voting_id, :user_id]
    end
  end
end
