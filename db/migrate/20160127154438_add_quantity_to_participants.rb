class AddQuantityToParticipants < ActiveRecord::Migration
  def change
    add_column :participants, :quantity, :integer
  end
end
