class AddLocaleToEvents < ActiveRecord::Migration
	def change
	  	change_table(:events) do |t|
		  	t.string :locale
		end
	end
end