class Voting < ActiveRecord::Base
  has_many :vote_products, through: :votes
  has_many :votes
  has_and_belongs_to_many :users, before_add: :check_voting_user

  def check_voting_user user
    if user.in? self.users
      raise Exception, 'You have voted already!'
    end
  end
end
