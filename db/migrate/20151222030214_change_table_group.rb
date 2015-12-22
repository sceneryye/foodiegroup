class ChangeTableGroup < ActiveRecord::Migration
  def up
    change_table(:groups) do |t|
      t.references :user, index: true
      
    end
  end
end
