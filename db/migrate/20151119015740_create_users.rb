class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users, options: 'ENGINE=MyISAM DEFAULT CHARSET=utf8' do |t|
      t.string :username,   null: false
      t.string :name
      t.string :mobile,  null: false
      t.column :sex, "ENUM('0','1','2')",:default=>'0' ###1:男；  2：女
      t.string :email
      t.string :password_digest, null: false
      t.column :role ,"ENUM('0', '1')",:default=>"0"   ###1管理员
      t.string :avator, limit:500
      t.string :profession, limit:45
      t.string :location, limit:45
      t.string :wexin_openid      
      t.integer :comments_count, default: 0
      t.integer :participants_count, default:0
      t.integer :events_count, default: 0


      t.timestamps
    end
   # add_index :users, :username, unique: true
  end
end
