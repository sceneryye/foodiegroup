#encoding:utf-8
class ParticipantsController < ApplicationController

  skip_before_action :verify_authenticity_token, only: [:wechat_notify_url, :participant_notify_url]

  before_action :validate_user!, except: :wechat_notify_url

  before_action only: [:edit, :update, :destroy,:wechat_pay] do
    validate_permission!(select_participant.user)
  end

  before_action :select_participant, only: [:edit, :show, :update, :destroy, :confirm_paid,:confirm_shiped]

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
      if params[:as_gift] == '1'
        area = ChinaCity.get(params[:gift_address][:province])
        address = ChinaCity.get(params[:gift_address][:province]) + params[:gift_address][:address]
        name = params[:gift_address][:name]
        mobile = params[:gift_address][:mobile]
        Rails.logger.info "----------------------#{area}"
        Rails.logger.info "----------------------#{address}"
        @participant.update_columns(area: area, address: address, name: name, mobile: mobile)
        Rails.logger.info "----------------------#{@participant.area}"
        Rails.logger.info "----------------------#{@participant.address}"
      end
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
    if Groupbuy.find_by(id: @participant.groupbuy_id).end_time > Time.current
      @note = session[:locale] == 'en' ? 'Note: The order will be shipped at the end of the deal.' : '将在三到4天发货'
    else
      @note = session[:locale] == 'en' ? 'Note: The order will be delivered within 3-4 days.' : '将在周末活动结束时统一发货'
    end
  end

  def wechat_pay
    @participant = Participant.find_by(id: params[:participant_id])
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
    event_name = current_title parent

    Rails.logger.info money
    data = {
      money: money,
      from: from,
      openid: openid,
      parent_id: parent.id,
      participant_id: @participant.id,
      user_id: @participant.user_id,
      parent_name: event_name,
      type_name: type_name
    }



    attach = "#{parent.id}_#{@participant.id}_#{@participant.user_id}"


    body = "tile=#{event_name[0..15]}"
    openid = openid
    detail = 'participant'
    total_fee = (money.to_f * 100).to_i
    @total = total_fee
    res_data_hash = pay_with_wechat(attach, body, openid, total_fee, detail)
    # return render :text => res_data_hash
    if res_data_hash["xml"]["return_code"] == 'SUCCESS'
      @url = "http://foodie.trade-v.com/#{type_name}/#{parent.id}?from=foodiepay"
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

  

  def wechat_notify_url
    Rails.logger.info "###########################{params}"
    begin

      data1 = Hash.from_xml request.body.read
      data = data1["xml"]
      Rails.logger.info "###########################{data}"

      if data["result_code"] == 'SUCCESS'
        if data['attach'].split('_').length == 3
          deal_with_participant_notify data
        elsif data['attach'].split('_').length == 2
          deal_with_downpayment_notify data
        end
      end
    rescue Exception => e
      Rails.logger.info e
    ensure
      render text: 'success'
    end
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
    area = params[:area].present? ? ChinaCity.get(params[:area]).try(:gsub, '市', '').try(:gsub, '省', '') : user_addresses.area.split('/')[0].try(:gsub, '市', '').try(:gsub, '省', '')
    Rails.logger.info "-------o-------#{area}"
    Rails.logger.info "-------oo-------#{params[:area].present?}"
    Rails.logger.info "-------ooo-------#{user_addresses.area}"
    if groupbuy.logistic_id
      logistics_item = groupbuy.logistic.logistics_items.where('areas LIKE ?', "%#{area}%").first

      price = logistics_item.price
      each_add = logistics_item.each_add
      freightage = (groupbuy.weight * num.to_i - 1 + BOX_WEIGHT).ceil * each_add + price.to_f
    else
      freightage = 0.0
    end
    total_price = (num.to_f * groupbuy.current_price + freightage).round(2)
    Rails.logger.info "----groupbuy.logistic_id=#{groupbuy.logistic_id}---freightage=#{freightage}---each_add=#{each_add}"
    render json: {freightage: freightage, total_price: total_price}.to_json
  end

  private

  def select_participant
    @participant = Participant.find_by(id: (params[:id] || params[:participant_id]))
  end

  def participant_params
    params.require(:participant).permit(:quantity, :remark)
  end

  def deal_with_participant_notify data
    groupbuy_id, participant_id, user_id = data["attach"].split('_')
    participant = Participant.find_by(id: participant_id)
    if participant.try(:pay_notify_status) == 0
      parent = participant.event_id.present? ? 'events' : 'groupbuys'
      participant.update_column(:status_pay, 1)
      # 模板消息
      openid = data["openid"]
      url = '/' + parent + '/groupbuy_id'
      title = participant.event_id.present? ? Event.find_by(id: groupbuy_id).en_title : Groupbuy.find_by(id: groupbuy_id).en_title
      data = {
        :first => {:value => 'Paid successfully(支付成功)', :color => "#173177"},
        :orderMoneySum => {:value => format('%.2f', (data["cash_fee"].to_f / 100.00).to_s), :color => "#173177"},
        :orderProductName => {:value => title, :color => "#173177"},
        :remark => {:value => 'Paid successfully and please check for more information in Groupmall!(您已支付成功！您可以在吃货帮查看更多详情!)', :color => "#173177"}
      }
      res_data = send_template_info_api openid, data, url
      Rails.logger.info "##########################res_data=#{res_data}"

      # 发送至boss
      nickname = User.find_by(id: user_id).nickname
      info = "#{nickname}刚刚完成了一笔支付：#{title}, 赶紧去看看哦～"
      send_info_preview_api info
    end
  end

  def deal_with_downpayment_notify data
    wishlist_id, user_id = data['attach'].split('_')
    total_fee = (data['total_fee'].to_f / 100).to_f
    downpayment = Downpayment.create(user_id: user_id, wishlist_id: wishlist_id, price: total_fee)
    # 模板消息
    title = 'Downpayment / 定金'
    remark = 'Your downpayment number is(您的定金编号为):' + downpayment.id.to_s
    data = {
      :first => {:value => '支付成功', :color => "#173177"},
      :orderMoneySum => {:value => data["cash_fee"].to_f / 100.00, :color => "#173177"},
      :orderProductName => {:value => title, :color => "#173177"},
      :remark => {:value => remark, :color => "#173177"}
    }
    send_template_info_api data["openid"], data

    # 发送至boss
    nickname = User.find_by(id: user_id).nickname
    info = "#{nickname}刚刚支付了一笔定金，共计#{total_fee}元。"
    send_info_preview_api info
  end

  
end
