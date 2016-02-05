class AddEnAndZhToTopic < ActiveRecord::Migration
  def change
    add_column :topics, :zh_title, :string
    add_column :topics, :zh_body, :string, limit: 5000
    add_column :topics, :en_title, :string
    add_column :topics, :en_body, :string, limit: 5000
  end
end
