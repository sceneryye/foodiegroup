class Site < ActiveRecord::Base

	has_many :groupbuy_sites, dependent: :destroy

  validates :area, presence: true
	validates :address, presence: true


end
