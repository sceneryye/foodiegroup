class CreateParticipants < ActiveRecord::Migration
  def change
    create_table :participants, options: 'ENGINE=MyISAM DEFAULT CHARSET=utf8' do |t|
      t.string :title,   null: false
      t.references :user,  index: true
      t.string :name, limit: 45
      t.string :mobile, limit: 45 
      t.string :address
      t.references :event,  index: true
      t.integer :status, default: 0
      t.decimal :amount, precision:10, scale:2
      t.string :remark, limit: 1000
      t.integer :status_pay, default:0

      t.timestamps
    end
  end
end
