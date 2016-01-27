class AddAreaToParticipants < ActiveRecord::Migration
  def change
    add_column :participants, :area, :string
    add_column :participants, :discount_id, :int
  end
end
