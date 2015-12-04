class Group < ActiveRecord::Base
  has_many :users, dependent: :destroy
  validates :name, presence: true, uniqueness: true
end
