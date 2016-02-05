class RemoveTileAndBodyFromEvent < ActiveRecord::Migration
  def change
    remove_columns :events, :title, :body
  end
end
