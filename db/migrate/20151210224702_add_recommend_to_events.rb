class AddRecommendToEvents < ActiveRecord::Migration
	def change
	  	change_table(:events) do |t|
		  	t.integer :recommend
		end
	end
end