class AddGroupIdToUsers < ActiveRecord::Migration
	def change
	  	change_table(:users) do |t|
		  	t.references :group
		end
	end
end