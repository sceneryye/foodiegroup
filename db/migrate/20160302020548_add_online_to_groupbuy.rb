class AddOnlineToGroupbuy < ActiveRecord::Migration
  def change
    add_column :groupbuys, :online, :boolean, default: true
  end
end
