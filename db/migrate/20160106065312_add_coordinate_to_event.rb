class AddCoordinateToEvent < ActiveRecord::Migration
  def change
    add_column :events, :x_coordinate, :integer
    add_column :events, :y_coordinate, :integer
  end
end
