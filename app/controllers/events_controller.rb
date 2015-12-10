#encoding:utf-8
require 'rest-client'
class EventsController < ApplicationController

  def index
    @events = Event.where(locale: session[:locale]).includes(:user)
  end

  def show
    @event  = Event.find(params[:id])
    @participants = @event.participants.includes(:user)
    @comments = @event.comments.includes(:user)

   #@goods_amount = Foodie::Participant.where

    if signed_in? 
       @plus_menu = [{name: '<i class="fa  fa-comment"></i>'.html_safe+' '+t(:new_comment), path: new_event_comment_path(@event)},
        {name: '<i class="fa  fa-sign-in"></i>'.html_safe+' '+t(:new_participant), path: new_event_participant_path(@event)}
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
      openids = "oVxC9uA1tLfpb7OafJauUm-RgzQ8"
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
    @event = Event.find_by_id(params[:id])
    if @event
      @event.delete
    end
    redirect_to events_path
  end

  private
  def set_event
    @event = event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :body,:end_time,:start_time,:event_type,
      :pic_url,:limited_people,:goods_big_than,:goods_small_than,:name,:mobile,:goods_unit,:price,:pic_url)
  end
end
