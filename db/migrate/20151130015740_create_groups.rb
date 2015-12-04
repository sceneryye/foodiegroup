class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups, options: 'ENGINE=MyISAM DEFAULT CHARSET=utf8' do |t|
      t.string :name, null: false
    end

    add_index :groups, :name, unique: true
  end
end
