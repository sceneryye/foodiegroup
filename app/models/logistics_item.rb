class LogisticsItem < ActiveRecord::Base
	belongs_to :logistic

	validates :areas, presence: true
	validates :price, presence: true
	validates :each_add, presence: true
	validates :logistic_id, presence: true

	default_scope {order 'updated_at DESC'}

  def default?
    self.default == 1
  end

  
end
