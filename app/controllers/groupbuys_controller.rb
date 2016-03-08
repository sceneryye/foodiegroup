#encoding:utf-8
require 'rest-client'
require 'digest/sha1'
class GroupbuysController < ApplicationController
  before_action :validate_user!, only: [:new, :edit, :update, :create, :destroy, :choose_or_new_groupbuy]
  before_action :login_with_mobile
  before_action :set_recommend, only: [:index]
  helper_method :cut_pic

  def index
    @groupbuys = Groupbuy.online.includes(:user).where('end_time > ?', Time.zone.now)
    @products = Groupbuy.online.includes(:user).where('end_time <= ?', Time.zone.now)
  end

  def show
    Rails.logger.info "---------------#{session[:locale]}"
    if params[:from] == 'foodiepay' && params[:total].present?
      @total = params[:total].to_f / 100
      @alert = true if params[:error_mesage] == 'success'
    end
    @parent = @groupbuy  = Groupbuy.find(params[:id])
    if @parent.pic_url.present?
      @title_pic = @groupbuy.pic_url.split(',').reject{|x| x.blank?}[0]
      @content_pic = @groupbuy.pic_url.split(',').reject{|x| x.blank?}[1..-1]
    else
      @title_pic = @parent.photos.first.try(:image)
      @content_pic = @parent.photos[1..-1]
    end
    
    @active = @groupbuy.comments.count > 10 ? true : false
    @participant = @parent.participants.new
    @comment = @parent.comments.new
    if current_user && current_user.role.in?(['1', '2'])
      @participants = @groupbuy.participants.includes(:user)
    elsif current_user
      @participants = @groupbuy.participants.includes(:user).where(user_id: current_user.try(:id))
    else
      @participants = []
    end
    more = 10
    @comments = @groupbuy.comments.includes(:user)[0...more]
    

    #微信share接口配置
    @title = "#{current_user.nickname if current_user.present?}推荐您加入团购：#{current_title @groupbuy}"
    @img_url = 'http://www.trade-v.com:5000' + @title_pic.to_s
    @desc = current_body(@groupbuy).present? ? current_body(@groupbuy).html_safe.gsub(/\s/, '').gsub('<p>', '').gsub('</p>', '') : ''
    @timestamp = Time.now.to_i
    @appId = WX_APP_ID
    @noncestr = random_str 16
    @jsapilist = ['onMenuShareTimeline', 'onMenuShareAppMessage', 'onMenuShareQQ', 'onMenuShareWeibo', 'onMenuShareQZone']
    @jsapi_ticket = get_jsapi_ticket
    post_params = {
      :noncestr => @noncestr,
      :jsapi_ticket => @jsapi_ticket,
      :timestamp => @timestamp,
      :url => request.url.gsub("localhost:5000", "foodie.trade-v.com")
    }
    @sign = create_sign_for_js post_params
    @a = [request.url, post_params, request.url.gsub("trade", "foodie.trade-v.com")]



    if signed_in? 
      @plus_menu = [{name: '<i class="fa  fa-comment"></i>'.html_safe+' '+t(:new_comment), path: new_groupbuy_comment_path(@groupbuy)},
        {name: '<i class="fa fa-user-plus"></i>'.html_safe+' '+t(:buy), path: new_groupbuy_participant_path(@groupbuy)}]

        if @participants.where(:user_id => current_user.id).size>0
          @again = '再次'     
        else
          @again = '立即'
        end

        @user_addresses = current_user.default_address      
        # if  @user_addresses.nil?
          # return redirect_to new_user_address_path(groupbuy_id: params[:groupbuy_id], from: 'new_participant')
        # end
      end

      

    end

    def new
     @groupbuy = Groupbuy.new
     session[:pic_file] = nil
     @photo = Photo.new
    end

    def choose_or_new_groupbuy
      @groupbuys = Groupbuy.offline.where(user_id: current_user.id)
    end

    def choose_from_groupbuys
      @groupbuys = Groupbuy.offline.where(user_id: current_user.id)
    end

    def new_from_groupbuy
      @groupbuy = Groupbuy.new
      @old_groupbuy = Groupbuy.find_by(params[:id])
    end

   def create
    modified_groupbuy_params = groupbuy_params
    modified_groupbuy_params[:en_title] = groupbuy_params[:en_title].blank? ? groupbuy_params[:zh_title] : groupbuy_params[:en_title]
    modified_groupbuy_params[:zh_title] = groupbuy_params[:zh_title].blank? ? groupbuy_params[:en_title] : groupbuy_params[:zh_title]
    modified_groupbuy_params[:en_body] = groupbuy_params[:en_body].blank? ? groupbuy_params[:zh_body] : groupbuy_params[:en_body]
    modified_groupbuy_params[:zh_body] = groupbuy_params[:zh_body].blank? ? groupbuy_params[:en_body] : groupbuy_params[:zh_body]
    modified_groupbuy_params[:recommend] = 5
    @groupbuy = Groupbuy.new(modified_groupbuy_params)
    @groupbuy.pic_url = ''
    @groupbuy.user = current_user
    @groupbuy.locale = session[:locale]

    if @groupbuy.save
      photo_ids = params[:photo_ids].split(',')
      Photo.where(id: photo_ids).update_all(groupbuy_id: @groupbuy.id)

      post_url = "http://www.trade-v.com/send_group_message_api"
      # openids = User.plunk(:weixin_openid)
      openids = "oVxC9uBr12HbdFrW1V0zA3uEWG8c"
      msgtype = "text"
      content = "吃货帮刚刚发布了一个新团购：#{current_title @groupbuy}, 赶紧来看看哦～"
      data_hash = {
        openids: openids,
        content: content,
        data: {msgtype: msgtype}
      }
      data_json = data_hash.to_json
      res_data_json = RestClient.post post_url, data_hash


      redirect_to groupbuy_url(@groupbuy), notice: '团购发布成功!'
    else
      render :new
    end
  end

  def edit
    @groupbuy = Groupbuy.find(params[:id])
    @pic = @groupbuy.pic_url.split(',').reject{|x| x.blank?}
    @photos = @groupbuy.photos
  end

  def update
    @groupbuy = Groupbuy.find(params[:id])
    Rails.logger.info @groupbuy.photos.pluck(:id)
    Rails.logger.info '###############'
    if params[:from] == 'admin_groupbuy_list'
      if params[:recommend].blank?
        return render :text => 'failed'
      end
      num = params[:recommend].to_i
      if Groupbuy.find(params[:id]).update(recommend: num)
        Rails.logger.info 'true'
        return render :text => 'success'
      end
    end

    if params[:from] == 'admin_edit_title'
      if params[:title].blank?
        return render :text => 'failed'
      end
      if params[:language] == 'zh'
        if Groupbuy.find(params[:id]).update(zh_title: params[:title])
          Rails.logger.info 'true'
          return render :text => 'success'
        end
      elsif params[:language] == 'en'
        if Groupbuy.find(params[:id]).update(en_title: params[:title])
          Rails.logger.info 'true'
          return render :text => 'success'
        end
      end
    end

    
    if params[:images]
      params[:images].each do |image|
        @groupbuy.photos.update(image: image)
      end
    end
    # 删除与团购关联的图片
    origin_ids = @groupbuy.photos.pluck(:id)
    if params[:photo_ids].present? || params[:delete_ids].present?
      ids = params[:photo_ids].split(',').select{|id|id.present?}
      Photo.where(id: ids).update_all(groupbuy_id: params[:id])
      
      Rails.logger.info origin_ids
      Rails.logger.info '###############'
      Rails.logger.info params[:delete_ids]
      if params[:delete_ids].present?
        delete_ids = params[:delete_ids].split(',').select{|id|id.present?}
        Photo.where(id: delete_ids).update_all(groupbuy_id: nil)
      end
    end

    if @groupbuy.update(groupbuy_params)
      if @groupbuy.end_time > Time.now && @groupbuy.recommend == 1
        @groupbuy.update(recommend: 5)
      end

      redirect_to groupbuy_url(@groupbuy), notice: '团购修改成功'
    else
      render :edit
    end
  end

  def upload
    uploaded_io = params[:file]

    if !uploaded_io.blank?
      extension = uploaded_io.original_filename.split('.')
      filename = "#{Time.now.strftime('%Y%m%d%H%M%S%L')}.#{extension[-1]}"
      filepath = "#{PIC_PATH}/groupbuys/#{filename}"
      File.open(filepath, 'wb') do |file|
        file.write(uploaded_io.read)
      end
      @pic_urls = ',/groupbuys/' + filename
      respond_to do |format|
        format.js
      end
    end
  end

  

  def destroy_pic
    @groupbuy = Groupbuy.find(params[:id])
    url = params[:url]
    pic_url = @groupbuy.pic_url
    new_pic_url = pic_url.gsub(url, '')
    pic_name = url.split('/').last
    if @groupbuy.update(pic_url: new_pic_url)
      `cd "#{Rails.root}"/public/groupbuys`
      `rm "#{pic_name}"`
      return render text: new_pic_url
    else
      return render text: 'failed'
    end
  end


  def destroy
    @groupbuy = Groupbuy.find(params[:id])
    @groupbuy.destroy
    respond_to do |format|
      format.js
      format.html {redirect_to groupbuys_path}
    end
  end

  def more_comments
    elements = []
    parent = params[:parent]
    start = params[:start].to_i
    over = params[:over].to_i
    comments = parent.capitalize.constantize.includes(:comments, :user).find(params[:id]).comments.includes(:user)[start...over]
    comments.each do |comment|
      elements << "<div class='row small-collapse'><div  class='columns small-12 comment'>" << comment.body.html_safe if comment.body << view_context.comment_info(comment) << "</div></div><hr />"
    end
    elements = elements.join
    return render text: elements
  end

  private

  

  def login_with_mobile
    if session[:mobile].present?
      user = User.find_by(mobile: session[:mobile])
      login user
    end
  end

  def set_groupbuy
    @groupbuy = Groupbuy.find(params[:id])
  end

  def groupbuy_params
    params.require(:groupbuy).permit(:en_title, :zh_title, :en_body, :zh_body, :end_time,:start_time,:groupbuy_type, :goods_maximal, :goods_minimal, :market_price,
      :groupbuy_price, :pic_url,:name,:mobile,:goods_unit,:price,:pic_url,:logistic_id,:weight, :goods_size, :goods_bbd)
  end

  def set_recommend
    gb = Groupbuy.where("end_time< ? AND recommend > ?", Time.zone.now, 1)
    gb.each do |groupbuy|
      groupbuy.update_columns(recommend: 1)
    end
  end
  
end
