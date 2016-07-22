class UserAddress < ActiveRecord::Base
	belongs_to :user

	validates :user, presence: true
	validates :name, presence: true
	validates :mobile, presence: true
	validates :address, presence: true

	default_scope {order 'updated_at DESC'}

  def default?
    self.default == 1
  end

	after_create  :initialize_user

	def initialize_user
		if self.user.name.blank?
			self.user.update(mobile: self.mobile)
			self.user.update(location: self.area)
			self.user.update(name: self.name)
		end
	end


end
