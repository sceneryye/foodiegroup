class UserInterests < ActiveRecord::Base

  belongs_to :topics
  belongs_to :events
  belongs_to :users

 
end
