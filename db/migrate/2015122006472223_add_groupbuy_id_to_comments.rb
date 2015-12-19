class AddGroupbuyIdToComments < ActiveRecord::Migration
	def change
	  	change_table(:comments) do |t|
		  	t.references :groupbuy
		end
	end
end