class AddEnTitleAndEnBodyToGroupbuy < ActiveRecord::Migration
  def change
    add_column :groupbuys, :en_title, :string
    add_column :groupbuys, :en_body, :string
  end
end
