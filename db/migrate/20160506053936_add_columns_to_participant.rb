class AddColumnsToParticipant < ActiveRecord::Migration
  def change
    add_column :participants, :kol_id, :integer
  end
end
