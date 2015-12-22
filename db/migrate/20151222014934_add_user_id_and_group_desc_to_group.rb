class AddUserIdAndGroupDescToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :user_id, :string
    add_column :groups, :group_desc, :string
  end
end
