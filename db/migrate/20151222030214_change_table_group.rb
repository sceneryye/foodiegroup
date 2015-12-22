class ChangeTableGroup < ActiveRecord::Migration
  def up
    remove_column :groups, :user_id
    change_table(:groups) do |t|
      t.references :user, index: true
      
    end
  end
end
