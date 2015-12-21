class CreateUserAddresses < ActiveRecord::Migration
  def change
    create_table :user_addresses, options: 'ENGINE=MyISAM DEFAULT CHARSET=utf8' do |t|      
      t.references :user,  index: true
      t.string :name, limit: 45, null: false
      t.string :mobile, limit: 45, nul:false
      t.string :address, limit: 500, null: false
      t.string :area     
      t.column :default, "TINYINT"

      t.timestamps
    end
  end
end
