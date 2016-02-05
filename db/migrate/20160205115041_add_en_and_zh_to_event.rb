class AddEnAndZhToEvent < ActiveRecord::Migration
  def change
    add_column :events, :zh_title, :string
    add_column :events, :zh_body, :string, limit: 5000
    add_column :events, :en_title, :string
    add_column :events, :en_body, :string, limit: 5000
  end
end
