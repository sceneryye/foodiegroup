class Topic < ActiveRecord::Base
  belongs_to :user
  belongs_to :forum
  has_many :comments, dependent: :destroy
  has_many :votes
  has_many :photos

  validates :title, presence: true
  validates :body,  presence: true, length: {minimum: 2}
  validates :user,  presence: true
  validates :forum, presence: true

  default_scope {order 'created_at DESC'}
end
