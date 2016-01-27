class AddLogisticIdToGroupbuys < ActiveRecord::Migration
  def change
    add_column :logistics, :default, :tinyint
  end
end
