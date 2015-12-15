class AddRecommendToEvents < ActiveRecord::Migration
	def change
	  	change_table(:events) do |t|
		  	t.integer :recommend,default: 0
		end
	end
end