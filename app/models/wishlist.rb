class Wishlist < ActiveRecord::Base
  has_many :downpayments
  belongs_to :user
  belongs_to :user
  before_save :online_status
  scope :desc, -> {order(created_at: :desc)}
  scope :online, -> {where(online: true)}


  def online_status
    update(online: false) if self.online.nil?
  end
end
