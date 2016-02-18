class AddAccessTokenToWechat < ActiveRecord::Migration
  def change
    add_column :wechats, :access_token, :string
    add_column :wechats, :access_token_expires_at, :integer
    add_column :wechats, :jsapi_ticket, :string
    add_column :wechats, :jsapi_ticket_expires_at, :integer
  end
end
