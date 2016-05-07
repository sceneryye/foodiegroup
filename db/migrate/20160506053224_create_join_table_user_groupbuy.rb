class CreateJoinTableUserGroupbuy < ActiveRecord::Migration
  	def change
	    create_join_table :users, :groupbuys do |t|
	       t.index [:user_id, :groupbuy_id]
	       t.index [:groupbuy_id, :user_id]
	    end
	end
end
