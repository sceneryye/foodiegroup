class Logistic < ActiveRecord::Base
	belongs_to :user

	has_many :groupbuy, dependent: :destroy
	has_many :logistics_items, dependent: :destroy

	validates :user, presence: true
	validates :name, presence: true

	default_scope {order 'updated_at DESC'}

  def default?
    self.default == 1
  end

  
end
