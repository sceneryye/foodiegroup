class AddAreaToParticipants < ActiveRecord::Migration
  def change
    add_column :participants, :area, :string
    add_column :participants, :discount_id, :integer
    add_column :participants, :quantity, :integer
  end
end
