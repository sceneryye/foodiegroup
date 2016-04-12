class WishlistsController < ApplicationController
  def new
    @wishlist = Wishlist.new
  end

  def create
    wishlist = Wishlist.new(wishlist_params)
    uploaded_io = wishlist_params[:picture]
    if uploaded_io.present?
      extension = uploaded_io.original_filename.split('.')
      filename = "#{Time.now.strftime('%Y%m%d%H%M%S%L')}#{rand(100)}.#{extension[-1]}"
      filepath = "#{PIC_PATH}/wishlists/#{filename}"
      localpath = "#{Rails.root}/public/#{filename}"
      content_type = uploaded_io.content_type
      file = File.open(filepath, 'wb') do |file|
       file.write(uploaded_io.read)
     end
     path = "#{PIC_PATH}/wishlists"
     resize filename, 'mini', 300, 300, path
     wishlist.picture = '/wishlists/mini/' + filename
   end
   if wishlist.save
    redirect_to wishlists_path
  else
    render 'new'
  end
end

def index
  @published_wishlists = Wishlist.online.desc
  @my_wishlists = Wishlist.where(user_id: current_user.id).desc
end

private
def wishlist_params
  params.require(:wishlist).permit(:title, :picture, :price, :description, :user_id)
end
end
