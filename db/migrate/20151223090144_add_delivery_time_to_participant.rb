class AddDeliveryTimeToParticipant < ActiveRecord::Migration
  def change
    add_column :participants, :delivery_time, :string
  end
end
