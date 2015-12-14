class AddStatusShipToParticipant < ActiveRecord::Migration
  def change
    add_column :participants, :status_ship, :int, default: 0
  end
end
