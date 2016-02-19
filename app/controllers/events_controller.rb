#encoding:utf-8
require 'rest-client'
class EventsController < ApplicationController
  before_action :validate_user!, only: [:new, :edit, :update, :create, :destroy]
  before_action :set_event, only: [:edit, :update, :destroy, :show]
  def index
    @events = Event.all.includes(:user)

    

  end

  def show
    @onload='onload="geocoder()"'
    @parent = @event  = Event.find(params[:id])
    @active = @event.comments.count > 10 ? true : false
    @participant = @parent.participants.new
    @comment = @parent.comments.new
    @participants = @event.participants.includes(:user)
    more = 10
    @comments = @event.comments.includes(:user)[0...more]

    if @parent.pic_url.present?
      @title_pic = @event.pic_url.split(',').reject{|x| x.blank?}[0]
      @content_pic = @event.pic_url.split(',').reject{|x| x.blank?}[1..-1]
    else
      @title_pic = @parent.photos.first.try(:image)
      @content_pic = @parent.photos[1..-1]
    end

    #微信share接口配置
    @title = "#{current_user.nickname if current_user.present?}推荐您加入活动：#{current_title @event}"
    @img_url = 'http://www.trade-v.com:5000' + @title_pic.to_s
    @desc = (current_body @event).html_safe.gsub(/\s/, '').gsub('<p>', '').gsub('</p>', '')
    @timestamp = Time.now.to_i
    @appId = WX_APP_ID
    @noncestr = random_str 16
    @jsapilist = ['onMenuShareTimeline', 'onMenuShareAppMessage', 'onMenuShareQQ', 'onMenuShareWeibo', 'onMenuShareQZone']
    @jsapi_ticket = get_jsapi_ticket
    post_params = {
      :noncestr => @noncestr,
      :jsapi_ticket => @jsapi_ticket,
      :timestamp => @timestamp,
      :url => request.url.gsub("localhost:5000", "vshop.trade-v.com")
    }
    @sign = create_sign_for_js post_params
    @a = [request.url, post_params, request.url.gsub("trade", "vshop.trade-v.com")]


    if signed_in? 
     @plus_menu = [{name: '<i class="fa  fa-comment"></i>'.html_safe+' '+t(:new_comment), path: new_event_comment_path(@event)},
      {name: '<i class="fa fa-user-plus"></i>'.html_safe+' '+t(:rsvp), path: new_event_participant_path(@event)}
    ]
    if @participants.where(:user_id => current_user.id).size>0
      @again = '再次'     
    else
      @again = '立即'
    end
  end

end

def new
 @event = Event.new
end

def create
  modified_event_params = event_params
  modified_event_params[:en_title] = event_params[:en_title].blank? ? event_params[:zh_title] : event_params[:en_title]
  modified_event_params[:zh_title] = event_params[:zh_title].blank? ? event_params[:en_title] : event_params[:zh_title]
  modified_event_params[:en_body] = event_params[:en_body].blank? ? event_params[:zh_body] : event_params[:en_body]
  modified_event_params[:zh_body] = event_params[:zh_body].blank? ? event_params[:en_body] : event_params[:zh_body]
  @event = Event.new(modified_event_params)
  @event.user = current_user
  @event.locale = session[:locale]

  uploaded_io = params[:file]
  if !uploaded_io.blank?
    extension = uploaded_io.original_filename.split('.')
    filename = "#{Time.now.strftime('%Y%m%d%H%M%S%L')}.#{extension[-1]}"
    filepath = "#{PIC_PATH}/events/#{filename}"
    localpath = "#{Rails.root}/public/events/#{filename}"
    File.open(filepath, 'wb') do |file|
      file.write(uploaded_io.read)
    end
        # event_params.merge!(:pic_url=>"/events/#{filename}")
        @event.pic_url = "/events/#{filename}"
      end

    #  return render :text=>  event_params



    if @event.save
      photo_ids = params[:photo_ids].split(',')
      Photo.where(id: photo_ids).update_all(event_id: @event.id)
      post_url = "http://www.trade-v.com/send_group_message_api"
      # openids = User.plunk(:weixin_openid)
      openids = "oVxC9uBr12HbdFrW1V0zA3uEWG8c"
      msgtype = "text"
      content = "吃货帮刚刚发布了一个新活动：#{current_title @event}, 赶紧来看看哦～"
      data_hash = {
        openids: openids,
        content: content,
        data: {msgtype: msgtype}
      }
      data_json = data_hash.to_json
      res_data_json = RestClient.post post_url, data_hash


      redirect_to event_url(@event), notice: '活动发布成功!'
    else
      render :new
    end
  end

  def edit
    @event = Event.find(params[:id])
    @photos = @event.photos
  end

  def update
    if params[:from] == 'admin_event_list'
      if params[:recommend].blank?
        return render :text => 'failed'
      end
      num = params[:recommend].to_i
      if Event.find(params[:id]).update(recommend: num)
        Rails.logger.info 'true'
        return render :text => 'success'
      end
    end
    
    # 删除与团购关联的图片
    origin_ids = @event.photos.pluck(:id)
    if params[:photo_ids].present? || params[:delete_ids].present?
      ids = params[:photo_ids].split(',').select{|id|id.present?}
      Photo.where(id: ids).update_all(event_id: params[:id])
      
      Rails.logger.info origin_ids
      Rails.logger.info '###############'
      Rails.logger.info params[:delete_ids]
      if params[:delete_ids].present?
        delete_ids = params[:delete_ids].split(',').select{|id|id.present?}
        Photo.where(id: delete_ids).update_all(event_id: nil)
      end
    end


    @event = Event.find(params[:id])
    if @event.update(event_params)
      redirect_to event_url(@event), notice: '活动修改成功'
    else
      render :edit
    end
  end

  

  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    respond_to do |format|
      format.js
      format.html {redirect_to events_path}
    end
  end

  def more_comments
    elements = []
    parent = params[:parent]
    start = params[:start].to_i
    over = params[:over].to_i
    comments = parent.capitalize.constantize.includes(:comments, :user).find(params[:id]).comments.includes(:user)[start...over]
    comments.each do |comment|
      elements << "<div class='row small-collapse'><div  class='columns small-12 comment'>" << comment.body.html_safe if comment.body << view_context.comment_info(comment) << "</div><hr />"
    end
    elements = elements.join
    return render text: elements
  end

  private
  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:zh_title, :en_title, :zh_body, :en_body, :end_time,:start_time,:event_type, :address, :x_coordinate, :y_coordinate,
      :pic_url,:limited_people,:goods_big_than,:goods_small_than,:name,:mobile,:goods_unit,:price,:pic_url)
  end
end
