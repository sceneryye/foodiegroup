class ChangeGroup < ActiveRecord::Migration

  def down
    remove_column :groups, :user_id
    remove_column :groups, :user_id_id
  end
  def up
    change_table(:groups) do |t|
      t.references :user, index: true
      
    end
  end
end
