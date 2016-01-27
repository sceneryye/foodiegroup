class AddFreightageToParticipants < ActiveRecord::Migration
  def change
    add_column :participants, :freightage, :int
    add_column :participants, :discount, :decimal, precision: 10, scale: 2
  end
end
