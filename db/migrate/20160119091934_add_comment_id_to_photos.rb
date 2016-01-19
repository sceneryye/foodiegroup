class AddCommentIdToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :comment_id, :integer
  end
end
