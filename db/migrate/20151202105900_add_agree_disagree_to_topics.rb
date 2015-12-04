class AddAgreeDisagreeToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :agree, :integer, default: 0
    add_column :topics, :disagree, :integer, default: 0
  end
end
