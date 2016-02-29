require 'convert_picture'
class PhotosController < ApplicationController
  include ConvertPicture
  before_action :set_photo, only: [:show, :edit, :update, :destroy]

  # GET /photos
  # GET /photos.json
  def index
    @photos = Photo.all

    respond_to do |format|
      format.html
      format.json
    end
  end

  # GET /photos/1
  # GET /photos/1.json
  def show
  end

  # GET /photos/new
  def new
    @photo = Photo.new
  end

  # GET /photos/1/edit
  def edit
  end

  # POST /photos
  # POST /photos.json
  def create
   uploaded_io = params[:file]
   if !uploaded_io.blank?
     extension = uploaded_io.original_filename.split('.')
     filename = "#{Time.now.strftime('%Y%m%d%H%M%S%L')}#{rand(100)}.#{extension[-1]}"
     filepath = "#{PIC_PATH}/#{params[:parent]}/#{filename}"
     localpath = "#{Rails.root}/public/#{filename}"
     content_type = uploaded_io.content_type
     file = File.open(filepath, 'wb') do |file|
       file.write(uploaded_io.read)
     end
     # resize the picture size
     path = "#{PIC_PATH}/#{params[:parent]}"
     resize filename, 'mini', 100, 100, path
     photo_params = {}
     photo_params[:image] = "/#{params[:parent]}/#{filename}"
     photo_params[:content_type] = content_type
     photo_params[:name] = uploaded_io.original_filename
     photo_params[:size] = (uploaded_io.size.to_f / 1024 / 1024).round(3).to_s + 'Mb'
     


     @photo = Photo.new(photo_params)
     @photo.save
     res = {id: @photo.id, pathname: @photo.image, filename: filename, origin_path: filepath}.to_json
     render json: res
   end
 end

  # PATCH/PUT /photos/1
  # PATCH/PUT /photos/1.json
  def update
    respond_to do |format|
      if @photo.update(photo_params)
        format.html { redirect_to @photo, notice: ' photo was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /photos/1
  # DELETE /photos/1.json
  def destroy
    @photo.destroy
    respond_to do |format|
      format.html { redirect_to photos_url }
      format.json
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_photo
      @photo = Photo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def photo_params
      params.require(:photo).permit!
    end
  end
