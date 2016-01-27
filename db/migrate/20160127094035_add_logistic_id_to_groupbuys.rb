class AddLogisticsIdToGroupbuys < ActiveRecord::Migration
  def change
    add_column :groupbuys, :logistic_id, :int
    add_column :groupbuys, :status, :tinyint, default: 1
end
