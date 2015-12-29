class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events, options: 'ENGINE=MyISAM DEFAULT CHARSET=utf8' do |t|
      t.string :title,   null: false
      t.column :event_type, "ENUM('tuan','offline')", null: false 
      t.string :pic_url, limit: 500, null: false     
      t.string :body, null: false         
      t.datetime :start_time,      null: false 
      t.datetime :end_time,      null: false
      t.references :user,  index: true
      t.integer :limited_people, default: 0
      t.decimal :price, precision:10, scale:2
      t.column :pay_type, "ENUM('online','offline')"
      t.string :name, limit: 45
      t.string :mobile, limit: 45       
      t.integer :comments_count, default: 0
      t.integer :participants_count, default:0      

      t.timestamps
    end
  end
end
