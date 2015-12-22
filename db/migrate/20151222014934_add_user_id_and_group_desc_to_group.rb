class AddUserIdAndGroupDescToGroup < ActiveRecord::Migration
  def change

    change_table(:groups) do |t|
      t.references :user, index: true
      t.string :group_desc
    end
  end
end
