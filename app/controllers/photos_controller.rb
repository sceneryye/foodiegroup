class PhotosController < ApplicationController
  def create
    @photo = Photo.new(photo_params)
    @photo.save
  end
end
