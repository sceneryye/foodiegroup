class Site < ActiveRecord::Base

  self.primary_key = 'id'

	has_many :groupbuy_sites, dependent: :destroy
  has_many :groupbuys, dependent: :destroy

  validates :area, presence: true
	validates :address, presence: true


end
