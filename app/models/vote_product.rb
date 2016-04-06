class VoteProduct < ActiveRecord::Base
  has_many :votings, through: :votes
  has_many :votes
end
