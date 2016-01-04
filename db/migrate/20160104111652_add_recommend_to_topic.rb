class AddRecommendToTopic < ActiveRecord::Migration
  def change
    add_column :topics, :recommend, :integer
  end
end
