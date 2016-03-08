class ChangeColumnToGroupbuy < ActiveRecord::Migration
  def change
    change_table(:groupbuys) do |t|
      t.remove :goods_bbd
      t.string :goods_bbd
    end
  end
end
