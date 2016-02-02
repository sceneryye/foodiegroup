#encoding:utf-8
class ParticipantsController < ApplicationController

  skip_before_action :verify_authenticity_token, only: :wechat_notify_url

  before_action :validate_user!, except: :wechat_notify_url

  before_action only: [:edit, :update, :destroy,:wechat_pay] do
    validate_permission!(select_participant.user)
  end

  before_action :select_participant, only: [:edit, :show, :update, :destroy, :confirm_paid,:confirm_shiped,:wechat_pay]

  before_action only: [:new, :create,:index] do
    if params[:groupbuy_id]
      @parent = Groupbuy.find(params[:groupbuy_id])
      @url = groupbuy_path(@parent)
    elsif params[:event_id]
      @parent = Event.find(params[:event_id])
      @url = event_path(@parent)
    end

    @user_addresses = current_user.user_addresses
    if  @user_addresses.size == 0
      redirect_to new_user_address_path(groupbuy_id: params[:groupbuy_id], from: 'new_participant')
    elsif  @user_addresses.where(default: 1).present?
      @user_addresses =  @user_addresses.where(default: 1)
    else
      @user_addresses =  @user_addresses.first
    end
  end

  def new
    @participant = @parent.participants.new
  end

  def index
    @participant = @parent.participants.new
    @participants = @parent.participants.includes(:user).limit(3)
    render layout: nil
  end

  def confirm_paid
    @participant.groupbuy
    if @participant.groupbuy_id
      owner = @participant.groupbuy.user
      return_url = groupbuy_url(@participant.groupbuy)
    else
      owner = @participant.event.user
      return_url = event_url(@participant.event)
    end

    if current_user == owner #只能由活动发起人修改支付状态
      @participant.update(:status_pay=>1)
    end

    redirect_to return_url, notice: '确认付款'
  end

  def confirm_shiped
    if is_admin?
      @participant.update(status_ship: 1, tracking_number: params[:tracking_number])
      return render :text => 'success'
    end
  end

  def create

    if params[:groupbuy_id].present?
      # address = params[:user_addresses_id].present? ? UserAddress.find_by(id: params[:user_addresses_id]) : current_user.default_address
      # params[:participant].merge!(:name=>address.name,:address=>address.address,:mobile=>address.mobile)
      

      delivery_time = params[:date] + '-' + params[:time]
      params[:participant].merge!(:delivery_time => delivery_time)
    end

    @participant = @parent.participants.new(participant_params)

    @participant.user = current_user

    if @participant.save
      notice =  '报名成功'
      if @participant.groupbuy_id
        redirect_to participant_path(@participant), notice: notice
      else 
        redirect_to event_path(@participant.event), notice: notice
      end
      
    else
      render :new
    end
    # else
    #   redirect_to event_url(@event), notice: '您已经报过名了'
    # end
  end

  def show
    @parent = @participant.groupbuy_id.present? ? Groupbuy.find_by(id: @participant.groupbuy_id) : Event.find_by(id: @participant.groupbuy_id)
    @path = @participant.groupbuy_id.present? ? groupbuy_path(@parent) : event_path(@parent)
    if @parent.pic_url.present?
      @title_pic = @parent.pic_url.split(',').reject{|x| x.blank?}[0]
      @content_pic = @parent.pic_url.split(',').reject{|x| x.blank?}[1..-1]
    else
      @title_pic = @parent.photos.first.try(:image)
      @content_pic = @parent.photos[1..-1]
    end
  end

  def wechat_pay

    if @participant.event_id
      parent = @participant.event
      type_name = 'events'
    else
      parent = @participant.groupbuy
      type_name = 'groupbuys'
    end

    money = @participant.total
    from = 'foodiegroup'
    openid = current_user.weixin_openid
    event_id = parent.id
    event_name = parent.title

    Rails.logger.info money
    data = {
      money: money,
      from: from,
      openid: openid,
      parent_id: parent.id,
      participant_id: @participant.id,
      user_id: @participant.user_id,
      parent_name: parent.title,
      type_name: type_name
    }
    return redirect_to "http://www.trade-v.com/foodies/foodie_pay?#{data.to_query}"
  end

  def wechat_notify_url
    Rails.logger.info '##########################1'
    if params["result_code"] == 'SUCCESS'
      Rails.logger.info '##########################2'
      groupbuy_id, participant_id, user_id = params["attach"].split('_')
      participant = Participant.find(participant_id)
      parent = participant.event_id.present? ? 'events' : 'groupbuys'
      participant.update(status_pay: 2)
      post_url = "http://www.trade-v.com/temp_info_api"
      openid = params["openid"]
      template_id = "E_Mfmg0TwyE3hRnccleURsU5QpqsPVsj0LD5dU4fu0Y"
      url = '/foodiegroup/' + parent + '/groupbuy_id'
      title = participant.event_id.present? ? Event.find_by(id: groupbuy_id).title : Groupbuy.find_by(id: groupbuy_id).title
      data = {
        :first => {:value => '支付成功', :color => "#173177"},
        :orderMoneySum => {:value => params["cash_fee"].to_f / 100.00, :color => "#173177"},
        :orderProductName => {:value => title, :color => "#173177"},
        :Remark => {:value => '您已支付成功！您可以在吃货帮查看更多详情', :color => "#173177"}
      }
      post_data = {
        openid: openid,
        template_id: template_id,
        url: url,
        data: data
      }
      RestClient.post post_url, post_data
      Rails.logger.info '##########################3'

      post_url = "http://www.trade-v.com/send_group_message_api"
      user = User.find_by(id: participant.user_id)

      # openids = User.plunk(:weixin_openid)
      openids = "oVxC9uBr12HbdFrW1V0zA3uEWG8c"
      msgtype = "text"
      content = "#{user.nickname}刚刚完成了一笔支付：#{title}, 赶紧去看看哦～"
      data_hash = {
        openids: openids,
        content: content,
        data: {msgtype: msgtype}
      }
      data_json = data_hash.to_json
      res_data_json = RestClient.post post_url, data_hash
      Rails.logger.info res_data_json
    end
    Rails.logger.info '##########################5'
    render text: 'ok'
  end

  def edit
  end

  def update
    if params[:from] == 'pay offline'
      id = params[:id]
      participant = Participant.find_by(id: id).update(status_pay: 2)
      return render json: {msg: 'success'}.to_json
    end
    if @participant.update(participant_params)
      if @participant.groupbuy
        return_url = groupbuy_url(@participant.groupbuy)
      else
        return_url = event_url(@participant.event)
      end
      notice =  '报名修改成功'
      redirect_to return_url, notice: notice
    else
      render :edit
    end
  end

  def destroy
    if @participant.groupbuy
      return_url = groupbuy_url(@participant.groupbuy)
    else
      return_url = event_url(@participant.event)
    end

    @participant.destroy
    notice =  '取消报名成功'
    redirect_to return_url, notice: notice
  end

  def cal_freightage
    num = params[:num]
    groupbuy = Groupbuy.find_by(id: params[:groupbuy_id])
    user_addresses = current_user.default_address
    # 默认运费
    area = user_addresses.area.split('/')[0]
    logistics_item = groupbuy.logistic.logistics_items.where('areas LIKE ?', "%#{area}%").first
    price = logistics_item.price
    each_add = logistics_item.each_add
    freightage = (groupbuy.weight * num.to_i - 1 + BOX_WEIGHT).ceil * each_add + price.to_f
    total_price = num.to_i * groupbuy.current_price + freightage 
    render json: {freightage: freightage, total_price: total_price}.to_json
  end

  private

  def select_participant
    @participant = Participant.find(params[:id])
  end

  def participant_params
    params.require(:participant).permit(:quantity, :remark)
  end
end
