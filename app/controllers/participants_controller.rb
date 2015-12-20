#encoding:utf-8
class ParticipantsController < ApplicationController

  skip_before_action :verify_authenticity_token, only: :wechat_notify_url
  before_action :validate_user!, except: :wechat_notify_url
  before_action only: [:edit, :update, :destroy] do
    validate_permission!(select_participant.user)
  end
  before_action :select_participant, only: [:edit, :update, :destroy]
  before_action only: [:new, :create,:index] {
    if params[:groupbuy_id]
      @parent = Groupbuy.find(params[:groupbuy_id])
    elsif params[:event_id]
      @parent = Event.find(params[:event_id])
    end
  }

  def new
    @participant = @parent.participants.new
  end

  def index
    @participant = @parent.participants.new
    @participants = @parent.participants.includes(:user)
  end

  def confirm_paid
    @participant = Participant.find(params[:id])
    if current_user = @participant.event.user #只能由活动发起人修改支付状态    
      @participant.update(:status_pay=>1)
    end
    redirect_to event_url(@participant.event), notice: '确认付款'
  end

  def confirm_shiped
    participant = Participant.find(params[:id])
    if is_admin?
      participant.update(status_ship: 1)
      return render :text => 'success'
    end
  end


  def create  

    # is_enrolled = @event.participants.where(:user_id => current_user.id).size
    # if  is_enrolled ==0
    @participant = @parent.participants.new(participant_params)
    @participant.user = current_user

    if @participant.save
      redirect_to event_url(@parent), notice: '活动报名成功'
    else
      render :new
    end
    # else
    #   redirect_to event_url(@event), notice: '您已经报过名了'
    # end
  end

  def wechat_pay
    money = params[:money].to_f
    from = 'foodiegroup'
    openid = params[:openid]
    event_id = params[:event_id]
    event_name = Event.find(event_id).title
    participant_id = params[:id]
    Rails.logger.info money
    data = {
      money: money,
      from: from,
      openid: openid,
      event_id: event_id,
      participant_id: participant_id,
      user_id: Participant.find(params[:id]).user_id,
      event_name: event_name
    }
    return redirect_to "http://www.trade-v.com/foodies/foodie_pay?#{data.to_query}"
  end

  def wechat_notify_url
    if params["result_code"] == 'SUCCESS'
      event_id, participant_id, user_id = params["attach"].split('_')
      Participant.find(participant_id).update(status_pay: 2)
      post_url = "http://www.trade-v.com/temp_info_api"
      openid = params["openid"]
      template_id = "E_Mfmg0TwyE3hRnccleURsU5QpqsPVsj0LD5dU4fu0Y"
      url = "http://182.254.137.73:5000/events/#{event_id}"
      title = Event.find(event_id).title
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
    end
  end

  def edit() end

    def update
      if @participant.update(participant_params)
        redirect_to event_url(@participant.event), notice: '活动报名修改成功'
      else
        render :edit
      end
    end

    def destroy
      @participant.destroy
      redirect_to event_url(@participant.event), notice: '取消报名成功'
    end

    private

    def select_participant
      @participant = Participant.find(params[:id])
    end

    def participant_params
      params.require(:participant).permit(:name,:mobile,:people_amount,:goods_amount,:address, :remark)
    end
  end
