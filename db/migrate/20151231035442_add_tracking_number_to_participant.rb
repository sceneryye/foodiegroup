class AddTrackingNumberToParticipant < ActiveRecord::Migration
  def change
    add_column :participants, :tracking_number, :string
  end
end
