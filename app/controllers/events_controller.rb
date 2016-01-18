#encoding:utf-8
require 'rest-client'
class EventsController < ApplicationController
before_action :validate_user!, only: [:new, :edit, :update, :create, :destroy]
  def index
    @events = Event.where(locale: session[:locale]).includes(:user)
  end

  def show
    @parent = @event  = Event.find(params[:id])
    @active = @event.comments.count > 10 ? true : false
    @participant = @parent.participants.new
    @comment = @parent.comments.new
    @participants = @event.participants.includes(:user)
    more = 10
    @comments = @event.comments.includes(:user)[0...more]

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
  @event = Event.new(event_params)
  @event.user = current_user
  @event.locale = session[:locale]

  uploaded_io = params[:file]
  if !uploaded_io.blank?
    extension = uploaded_io.original_filename.split('.')
    filename = "#{Time.now.strftime('%Y%m%d%H%M%S')}.#{extension[-1]}"
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
      post_url = "http://www.trade-v.com/send_group_message_api"
      # openids = User.plunk(:weixin_openid)
      openids = "oVxC9uBr12HbdFrW1V0zA3uEWG8c"
      msgtype = "text"
      content = "吃货帮刚刚发布了一个新活动：#{@event.title}, 赶紧来看看哦～"
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
    uploaded_io = params[:file]
    if !uploaded_io.blank?
      extension = uploaded_io.original_filename.split('.')
      filename = "#{Time.now.strftime('%Y%m%d%H%M%S')}.#{extension[-1]}"
      filepath = "#{PIC_PATH}/events/#{filename}"
      File.open(filepath, 'wb') do |file|
        file.write(uploaded_io.read)
      end
      event_params.merge!(:pic_url=>"/events/#{filename}")

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
    comments = parent.capitalize.constantize.includes(:forum, :comments, :user).find(params[:id]).comments.includes(:user)[start...over]
    comments.each do |comment|
      elements << "<div class='row small-collapse'><div  class='columns small-12 comment'>" << comment.body.html_safe if comment.body << view_context.comment_info(comment) << "</div><hr />"
    end
    elements = elements.join
    return render text: elements
  end

  private
  def set_event
    @event = event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :body,:end_time,:start_time,:event_type, :address, :x_coordinate, :y_coordinate,
      :pic_url,:limited_people,:goods_big_than,:goods_small_than,:name,:mobile,:goods_unit,:price,:pic_url)
  end
end
