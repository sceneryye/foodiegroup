class Photo < ActiveRecord::Base
  belongs_to :groupbuy
  belongs_to :event
  mount_uploader :image, PictureUploader
end
