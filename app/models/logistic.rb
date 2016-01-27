class Logistic < ActiveRecord::Base
	belongs_to :user

	validates :user, presence: true
	validates :name, presence: true
	validates :mobile, presence: true
	validates :address, presence: true

	default_scope {order 'updated_at DESC'}

  def default?
    self.default == 1
  end

  
end
