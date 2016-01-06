#encoding:utf-8
require 'rest-client'
class GroupbuysController < ApplicationController
before_action :validate_user!, only: [:new, :edit, :update, :create, :destroy]
  def index
    @groupbuys = Groupbuy.where(locale: session[:locale]).includes(:user)
  end

  def show
    @parent = @groupbuy  = Groupbuy.find(params[:id])
    @participant = @parent.participants.new
    @comment = @parent.comments.new
    @participants = @groupbuy.participants.includes(:user)
    more = 10
    @comments = @groupbuy.comments.includes(:user)[0...more]

    if current_user
      @user_addresses = current_user.user_addresses
      if  @user_addresses.size == 0
        return redirect_to new_user_address_path(groupbuy_id: params[:groupbuy_id], from: 'new_participant')
      elsif  @user_addresses.where(default: 1).present?
        @user_addresses =  @user_addresses.where(default: 1)
      else
        @user_addresses =  @user_addresses.first
      end
    end

   #@amount = Foodie::Participant.where

   if signed_in? 
     @plus_menu = [{name: '<i class="fa  fa-comment"></i>'.html_safe+' '+t(:new_comment), path: new_groupbuy_comment_path(@groupbuy)},
      {name: '<i class="fa fa-user-plus"></i>'.html_safe+' '+t(:buy), path: new_groupbuy_participant_path(@groupbuy)}
    ]
    if @participants.where(:user_id => current_user.id).size>0
      @again = '再次'     
    else
      @again = '立即'
    end
  end

end

def new
 @groupbuy = Groupbuy.new
end

def create
  @groupbuy = Groupbuy.new(groupbuy_params)
  @groupbuy.user = current_user
  @groupbuy.locale = session[:locale]

  uploaded_io = params[:file]
  if !uploaded_io.blank?
    extension = uploaded_io.original_filename.split('.')
    filename = "#{Time.now.strftime('%Y%m%d%H%M%S')}.#{extension[-1]}"
    filepath = "#{PIC_PATH}/groupbuys/#{filename}"
    File.open(filepath, 'wb') do |file|
      file.write(uploaded_io.read)
    end
        # groupbuy_params.merge!(:pic_url=>"/groupbuys/#{filename}")
        @groupbuy.pic_url = "/groupbuys/#{filename}"
      end

    #  return render :text=>  groupbuy_params



    if @groupbuy.save
      post_url = "http://www.trade-v.com/send_group_message_api"
      # openids = User.plunk(:weixin_openid)
      openids = "oVxC9uBr12HbdFrW1V0zA3uEWG8c"
      msgtype = "text"
      content = "吃货帮刚刚发布了一个新团购：#{@groupbuy.title}, 赶紧来看看哦～"
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
  end

  def update
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
      if Groupbuy.find(params[:id]).update(title: params[:title])
        Rails.logger.info 'true'
        return render :text => 'success'
      end
    end

    uploaded_io = params[:file]
    if !uploaded_io.blank?
      extension = uploaded_io.original_filename.split('.')
      filename = "#{Time.now.strftime('%Y%m%d%H%M%S')}.#{extension[-1]}"
      filepath = "#{PIC_PATH}/groupbuys/#{filename}"
      File.open(filepath, 'wb') do |file|
        file.write(uploaded_io.read)
      end
      groupbuy_params.merge!(:pic_url=>"/groupbuys/#{filename}")

    end


    @groupbuy = Groupbuy.find(params[:id])
    if @groupbuy.update(groupbuy_params)
      redirect_to groupbuy_url(@groupbuy), notice: '团购修改成功'
    else
      render :edit
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
  def set_groupbuy
    @groupbuy = Groupbuy.find(params[:id])
  end

  def groupbuy_params
    params.require(:groupbuy).permit(:title, :body,:end_time,:start_time,:groupbuy_type, :goods_maximal, :goods_minimal, :market_price,
      :pic_url,:limited_people,:goods_big_than,:goods_small_than,:name,:mobile,:goods_unit,:price,:pic_url)
  end
end
