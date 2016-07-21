class GroupbuySite < ActiveRecord::Base

	belongs_to :site
  belongs_to :groupbuy
	validates :site, presence: true


end
