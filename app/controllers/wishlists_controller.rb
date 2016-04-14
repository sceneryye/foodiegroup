class WishlistsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :downpayment_notify_url
  def new
    @wishlist = Wishlist.new
  end

  def edit
    @wishlist = Wishlist.find_by(id: params[:id])
  end

  def update
    wishlist = Wishlist.find_by(id: params[:id])
    data = wishlist_params
    data.delete(:picture)
    
    picture = ''
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
     picture = '/wishlists/mini/' + filename
   end
   if picture.present?
     data.merge!(picture: picture)
   end
   Rails.logger.info picture
   Rails.logger.info data
   if wishlist.update(data)
    redirect_to wishlists_management_path
  else
    render 'edit'
  end
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
  redirect_to my_wishlists_path(current_user)
else
  render 'new'
end
end

def index
  @published_wishlists = Wishlist.online.desc
  @my_wishlists = Wishlist.where(user_id: current_user.id).desc
end

def downpayment_with_wechat
  user_id = params[:user_id]
  wishlist_id = params[:wishlist_id]
  attach = "#{wishlist_id}_#{user_id}"
  body = 'downpayment'
  openid = params[:openid]
  total_fee = (params[:down_payment].to_f * 100).to_i
  Rails.logger.info "---------------#{total_fee}"
  detail = 'downpayment'
  res_data_hash = pay_with_wechat(attach, body, openid, total_fee, detail)

  if res_data_hash["xml"]["return_code"] == 'SUCCESS'
    @url = "http://foodie.trade-v.com/wishlists?from=foodiepay&total=#{total_fee}"
    prepay_id = res_data_hash["xml"]["prepay_id"]
    @timestamp = Time.now.to_i
    @nonce_str = random_str 32
    @package = "prepay_id=#{prepay_id}"
    @appId = WX_APP_ID
    data = {:appId => @appId, :timeStamp => @timestamp, :nonceStr => @nonce_str, :package => @package, :signType => 'MD5'}
    @paySign = create_sign data
    render :layout => false
  else
    render :text => res_data_hash
  end
end

def destroy
  @id = params[:id]
  wishlist = Wishlist.find_by(params[:id])
  pic_url =  "#{Rails.root}/public#{wishlist.picture}"
  pic_mini_url = "#{Rails.root}/public#{wishlist.picture.sub('/mini', '')}"
  Rails.logger.info pic_url
  Rails.logger.info pic_mini_url
  if wishlist.destroy
    `rm "#{pic_url}"`
    `rm "#{pic_mini_url}"`
  end
  respond_to do |format|
    format.html {redirect_to wishlists_path}
    format.js
  end
end



def publish_wishlist
  id = params[:id]
  down_payment = params[:down_payment].to_f
  if Wishlist.find_by(id: id).update(online: true, down_payment: down_payment)
    notice = session[:locale] == 'zh' ? '发布成功！' : 'Published Successfully!'
  else
    notice = session[:locale] == 'zh' ? '发布失败！' : 'Publish Failed!'
  end
  render json: {msg: 'ok', notice: notice}
end

private
def wishlist_params
  params.require(:wishlist).permit(:title, :picture, :price, :description, :user_id)
end
end
