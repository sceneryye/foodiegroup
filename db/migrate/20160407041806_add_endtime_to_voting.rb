class AddEndtimeToVoting < ActiveRecord::Migration
  def change
    add_column :votings, :end_time, :datetime
  end
end
