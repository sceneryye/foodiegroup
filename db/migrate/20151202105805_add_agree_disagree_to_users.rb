class AddAgreeDisagreeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :agree, :integer, default: 0
    add_column :users, :disagree, :integer, default: 0
  end
end
