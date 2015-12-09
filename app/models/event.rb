class Event < ActiveRecord::Base
	belongs_to :user
	
	has_many :participants, dependent: :destroy
	has_many :comments, dependent: :destroy
  has_many :votes, dependent: :destroy

	validates :body,  presence: true
	validates :title,  presence: true
	#validates :end_time, presence: true
	#validates :start_time, presence: true

 	default_scope {order 'participants_count DESC,created_at DESC'}
end
