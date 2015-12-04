class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags, options: 'ENGINE=MyISAM DEFAULT CHARSET=utf8' do |t|
      t.string :name,   null: false
      t.integer :rate, :default=>0
      t.string :url

      t.timestamps
    end
  end
end
