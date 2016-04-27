class Groupbuy < ActiveRecord::Base
	enum tag: [:deal, :groupbuy]
	belongs_to :user
	belongs_to :logistic



	has_many :participants, dependent: :destroy
	has_many :comments, dependent: :destroy
	has_many :photos, :inverse_of => :groupbuy, :dependent => :destroy
	accepts_nested_attributes_for :photos, allow_destroy: true



	# validates :end_time, presence: true
	# validates :start_time, presence: true
	validates :goods_unit,  presence: true
	validates :price,  presence: true
	validates :market_price, presence: true
	validates :groupbuy_price, presence: true
	validates :goods_minimal,  presence: true
	validates :goods_maximal,  presence: true
	validate :check_duration

	def check_duration
		return if self.start_time.blank? || self.end_time.blank?
		if self.start_time > self.end_time
			errors.add(:base, :duration)
		end
	end

	def target_completed
		return nil if self.deal?
		total_quantity =	Participant.where(groupbuy_id: self.id).sum(:quantity) * self.weight.to_f
		[(total_quantity.to_f / self.target.to_f).to_s, target - total_quantity]
	end

	scope :online, -> {where('online = ? and start_time < ?', true, Time.now).order('recommend DESC, created_at DESC')}
	scope :online_groupbuy, -> {where('online = ?', true).order('recommend DESC, created_at DESC')}
	scope :offline, -> {where(online: false).order('created_at DESC')}
	default_scope {order('recommend DESC, created_at DESC')}

	def current_price
		return self.price  if Time.now > self.end_time
		self.groupbuy_price
	end

	def current_market_price
		return self.market_price*1.2  if Time.now > self.end_time
		self.market_price
	end



end
