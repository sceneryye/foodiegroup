class AddAgreeDisagreeToEvents < ActiveRecord::Migration
  def change
    add_column :events, :agree, :integer, default: 0
    add_column :events, :disagree, :integer, default: 0
  end
end
