class Vote < ActiveRecord::Base
  belongs_to :voting
  belongs_to :vote_product
end
