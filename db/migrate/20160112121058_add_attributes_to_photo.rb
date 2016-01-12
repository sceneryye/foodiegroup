class AddAttributesToPhoto < ActiveRecord::Migration
  def change
    add_column :photos, :name, :string
    add_column :photos, :size, :string
    add_column :photos, :content_type, :string
  end
end
