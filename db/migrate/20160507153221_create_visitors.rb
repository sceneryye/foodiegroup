class CreateVisitors < ActiveRecord::Migration
  	def change
	    create_table :visitors do |t|
		       t.references :user,  index: true
		       t.integer :visitor_id
		    t.timestamps
	    end
	end
end
