class AddAgreeDisagreeToComments < ActiveRecord::Migration
  def change
    add_column :comments, :agree, :integer, default: 0
    add_column :comments, :disagree, :integer, default: 0
  end
end
