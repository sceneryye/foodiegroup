class AddColumnsToUser < ActiveRecord::Migration
  def change
    add_column :users, :kol, "ENUM('0', '1')",:default=>"0" 
  end
end
