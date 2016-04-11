class AddPayNotifyStatusToParticipant < ActiveRecord::Migration
  def change
    add_column :participants, :pay_notify_status, :integer, default: 0
  end
end
