class Participant < ActiveRecord::Base
	belongs_to :user
	belongs_to :event, counter_cache: true
	belongs_to :groupbuy, counter_cache: true

	validates :amount,  presence: true
	validates :name,  presence: true
  validates :mobile,  presence: true

	default_scope {order 'created_at DESC'}
 
end
