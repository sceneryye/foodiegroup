class AddRefreshTokenExpiresAtToWechat < ActiveRecord::Migration
  def change
    add_column :wechats, :auth_refresh_token_expires_at, :integer
  end
end
