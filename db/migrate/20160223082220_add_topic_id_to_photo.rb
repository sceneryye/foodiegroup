class AddTopicIdToPhoto < ActiveRecord::Migration
  def change
    add_column :photos, :topic_id, :integer
  end
end
