class AddNicknameToUsers < ActiveRecord::Migration
	def change
	  	change_table(:users) do |t|
		  	t.string :group
		end
	end
end