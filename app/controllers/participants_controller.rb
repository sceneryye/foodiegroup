#encoding:utf-8
class ParticipantsController < ApplicationController
 
  before_action :validate_user!
  before_action only: [:edit, :update, :destroy] do
    validate_permission!(select_participant.user)
  end
  before_action :select_participant, only: [:edit, :update, :destroy]
  before_action only: [:new, :create] {@event = Event.find(params[:event_id])}

  def new
    @participant = @event.participants.new
  end

  def confirm_paid
    @participant = Participant.find(params[:id])
    if current_user = @participant.event.user #只能由活动发起人修改支付状态    
      @participant.update(:status_pay=>1)
    end
    redirect_to event_url(@participant.event), notice: '确认付款'
  end


  def create  
   
    # is_enrolled = @event.participants.where(:user_id => current_user.id).size
    # if  is_enrolled ==0
      @participant = @event.participants.new(participant_params)
      @participant.user = current_user

      if @participant.save
        redirect_to event_url(@event), notice: '活动报名成功'
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
    return redirect_to "http://www.trade-v.com/foodie/foodie_pay?#{data.to_query}"
    # url = "http://www.trade-v.com/vshop/1/payments"

    # res_data_hash = RestClient.get url, {params: data}
    # return render :text => res_data_hash

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
    params.require(:participant).permit(:name,:mobile,:people_amount,:goods_amount,:address)
  end
end
