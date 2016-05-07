class CreateHongbaos < ActiveRecord::Migration
  def change
    create_table :hongbaos do |t|
     	
      	t.references :user,  index: true
      	t.references :participant, index: true
      	t.decimal :amount, precision:10, scale:2, null: false
      	t.integer :status, default: 0
      	t.text :return_message

      t.timestamps
    end
  end
end
