class RemoveTitleAndBodyFromGroupbuy < ActiveRecord::Migration
  def change
    remove_columns :groupbuys, :title, :body
  end
end
