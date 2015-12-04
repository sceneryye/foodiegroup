class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  belongs_to :comment
  belongs_to :topic
end
