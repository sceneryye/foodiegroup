class AddLocaleToTags < ActiveRecord::Migration
	def change
		change_table(:tags) do |t|
			t.string :locale
		end
	end
end
