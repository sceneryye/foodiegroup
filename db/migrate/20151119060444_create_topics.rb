class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics, options: 'ENGINE=MyISAM DEFAULT CHARSET=utf8' do |t|
      	t.string    :title, null: false
      	t.text      :body,  null: false
      	t.integer	:comments_count, default: 0
      	
      	t.references :user,  index: true
      	t.references :forum, index: true

      t.timestamps
    end
  end
end
