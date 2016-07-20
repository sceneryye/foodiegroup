class GroupbuySite < ActiveRecord::Base

	belonges_to :site
  belonges_to :groupbuy
	validates :site, presence: true


end
