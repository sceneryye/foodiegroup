#encoding:utf-8
class ParticipantsController < ApplicationController

  skip_before_action :verify_authenticity_token, only: :wechat_notify_url

  before_action :validate_user!, except: :wechat_notify_url

  before_action only: [:edit, :update, :destroy,:wechat_pay] do
    validate_permission!(select_participant.user)
  end

  before_action :select_participant, only: [:edit, :update, :destroy, :confirm_paid,:confirm_shiped,:wechat_pay]

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

    if !params[:groupbuy_id].nil?
      address = params[:user_addresses_id].present? ? UserAddress.find_by(id: params[:user_addresses_id]) : current_user.default_address
      params[:participant].merge!(:name=>address.name,:address=>address.address,:mobile=>address.mobile)
      

      Rails.logger.info "#################{address}"
      delivery_time = params[:date] + '-' + params[:time]
      params[:participant].merge!(:delivery_time => delivery_time)
    end

    @participant = @parent.participants.new(participant_params)

    @participant.user = current_user

    if @participant.save
      notice =  '报名成功'
      if params[:groupbuy_id]
        redirect_to groupbuy_url(@parent), notice: notice
      else
        redirect_to event_url(@parent), notice: notice
      end
    else
      render :new
    end
    # else
    #   redirect_to event_url(@event), notice: '您已经报过名了'
    # end
  end

  def wechat_pay

    if @participant.event_id
      parent = @participant.event
      type_name = 'events'
    else
      parent = @participant.groupbuy
      type_name = 'groupbuys'
    end

    money = @participant.amount  * parent.price.to_f
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
    if params["xml"]["result_code"] == 'SUCCESS'
      groupbuy_id, participant_id, user_id = params["xml"]["attach"].split('_')
      participant = Participant.find(participant_id)
      parent = participant.event_id.present? ? 'events' : 'groupbuys'
      participant.update(status_pay: 2)
      post_url = "http://www.trade-v.com/temp_info_api"
      openid = params["xml"]["openid"]
      template_id = "E_Mfmg0TwyE3hRnccleURsU5QpqsPVsj0LD5dU4fu0Y"
      url = '/foodiegroup/' + parent + '/groupbuy_id'
      title = participant.event_id.present? ? Event.find_by(id: groupbuy_id).title : Groupbuy.find_by(id: groupbuy_id).title
      data = {
        :first => {:value => '支付成功', :color => "#173177"},
        :orderMoneySum => {:value => params["xml"]["cash_fee"].to_f / 100.00, :color => "#173177"},
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
    end
  end

  def edit() end

  def update
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

  private

    def select_participant
      @participant = Participant.find(params[:id])
    end

    def participant_params
      params.require(:participant).permit(:name,:mobile,:amount,:amount,:address, :remark)
    end
end
