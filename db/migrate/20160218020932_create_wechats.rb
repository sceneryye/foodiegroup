class CreateWechats < ActiveRecord::Migration
  def change
    create_table :wechats do |t|
      t.string :auth_access_token
      t.integer :auth_access_token_expires_at
      t.string :auth_refresh_token

      t.timestamps null: false
    end
  end
end
