class CreateLogistics < ActiveRecord::Migration
  def change
    create_table :logistics do |t|
      t.references :user,  index: true
      t.string :name

      t.timestamps
    end
  end
end
