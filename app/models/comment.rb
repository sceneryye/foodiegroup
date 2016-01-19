class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :topic, counter_cache: true
  belongs_to :event, counter_cache: true
  belongs_to :groupbuy, counter_cache: true
  has_many :votes
  has_many :photos

  validates :body,  presence: true
  validates :user_id,  presence: true
  default_scope {order 'created_at DESC'}
end
