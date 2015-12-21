class Participant < ActiveRecord::Base
	belongs_to :user
	belongs_to :event, counter_cache: true
	belongs_to :groupbuy, counter_cache: true

	#validates :end_time, presence: true
	#validates :start_time, presence: true

	default_scope {order 'created_at DESC'}
 
end
