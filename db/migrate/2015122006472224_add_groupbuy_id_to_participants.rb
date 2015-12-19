class AddGroupbuyIdToParticipants < ActiveRecord::Migration
	def change
	  	change_table(:participants) do |t|
		  	t.references :groupbuy
		end
	end
end