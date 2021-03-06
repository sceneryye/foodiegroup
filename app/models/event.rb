class Event < ActiveRecord::Base
	belongs_to :user

	has_many :participants, dependent: :destroy
	has_many :comments, dependent: :destroy
	has_many :votes
	has_many :photos, :inverse_of => :event, :dependent => :destroy
	accepts_nested_attributes_for :photos, allow_destroy: true

	validates :end_time, presence: true
	validates :start_time, presence: true
	# validates :pic_url, presence: true
	validate :check_duration

	def check_duration
		return if self.start_time.blank? || self.end_time.blank?
		if self.start_time > self.end_time
			errors.add(:base, :duration)
		end
	end

	default_scope {order 'recommend DESC,created_at DESC'}

	def event_duration
		seconds = end_time.to_i - start_time.to_i
		days = seconds / 3600 / 24
		hours = seconds / 3600 % 24
		minutes = seconds / 60 % 60
		[days.to_s, hours.to_s, minutes.to_s]
	end
end
