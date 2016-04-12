class Wishlist < ActiveRecord::Base
  belongs_to :user
  before_save :online_status
  scope :desc, -> {order(created_at: :desc)}
  scope :online, -> {where(online: true)}


  def online_status
    update(online: false) if self.online.nil?
  end
end
