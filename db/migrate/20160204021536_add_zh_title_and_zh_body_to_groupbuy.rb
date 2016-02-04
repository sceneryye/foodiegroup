class AddZhTitleAndZhBodyToGroupbuy < ActiveRecord::Migration
  def change
    add_column :groupbuys, :zh_title, :string
    add_column :groupbuys, :zh_body, :string
  end
end
