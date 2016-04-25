#encoding:utf-8
require 'convert_picture'
class ApplicationController < ActionController::Base
  include SessionsHelper
  include ApplicationHelper
  include ConvertPicture
  protect_from_forgery with: :exception
  helper_method :signed_in?, :current_user,:forum_id, :cut_pic

  before_action :set_locale,  except: :wechat_notify_url
  before_action :force_sign_in

  


  private

  def show_user_agent
    Rails.logger.info request.user_agent
  end

  def cut_pic photo
    other_img photo, 'mini'
  end

  def set_locale
    # 可以將 ["en", "zh-TW"] 設定為 VALID_LANG 放到 config/environment.rb 中
    if params[:locale] && I18n.available_locales.include?( params[:locale].to_sym )
      session[:locale] = params[:locale]
    end
    session[:locale] ||= 'en'
    Rails.logger.info "--------#{session[:locale]}"

    I18n.locale = session[:locale] || I18n.default_locale
  end

  def login(user)
    session[:user_id] = user.id
  end

  def auto_login
    if !params[:openid].blank? && current_user.nil?
      session[:openid] = params[:openid].split('_shop')[0]

      session[:avatar] = params[:avatar]
      session[:nickname] = params[:nickname]
      user = User.where(:weixin_openid=>session[:openid])
      if user.size>0
        @user = user.first do |u|
          u.avatar = session[:avatar]
          u.nickname = session[:nickname]
        end.save
        login user.first
        redirect_to root_path #清空传过来的参数

      end
    end
    if current_user.nil?
      session[:locale] = 'zh'
    end
  end

  

  def logout
    session[:user_id] = nil
    session[:openid] = nil
    session[:mobile] = nil
    session.delete(:user_id)
    session.delete(:openid)
    session.delete(:mobile)
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    #@current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def forum_id
    if session[:locale]=='en'
      @forum_id=2
    else
      @forum_id=1
    end
  end

  def signed_in?
    current_user
  end

  def validate_user!
    unless signed_in?
      #redirect_to register_path(return_url: request.url.gsub('localhost:5000', 'foodie.trade-v.com')), alert: '请先登录！'
    end
  end

  def force_sign_in
    if !signed_in? && request.user_agent.match(/MicroMessenger/)
      redirect_to wx_auto_login_path(return_url: request.url.gsub('localhost:5000', 'foodie.trade-v.com'))
    end
  end

  def pay_with_wechat attach, body, openid, total_fee, detail
    weixin_appid = WX_APP_ID
    weixin_appsecret = WX_APP_SECRET
    mch_id = WX_MCH_ID

    nonce_str = random_str 32
    out_trade_no = Time.new.to_i.to_s + rand(10 ** 10).to_s.rjust(10, '0')


    spbill_create_ip = '182.254.138.119'
    trade_type = 'JSAPI'

    notify_url = 'http://foodie.trade-v.com/wechat_notify_url'
    post_data_hash = {:appid => weixin_appid, :mch_id => mch_id, :nonce_str => nonce_str, :body => body, :out_trade_no => out_trade_no, :total_fee => total_fee, :attach => attach, :openid => openid, :spbill_create_ip => spbill_create_ip, :notify_url => notify_url, :trade_type => trade_type, detail: detail}
    sign = create_sign post_data_hash
    post_data_hash[:sign] = sign
    post_data_xml = to_label_xml post_data_hash

    post_url = 'https://api.mch.weixin.qq.com/pay/unifiedorder'
    Hash.from_xml(RestClient.post post_url, post_data_xml)
  end

  def validate_permission!(user)
    Rails.logger.info "------current_user.id=#{current_user.try(:id)}"
    Rails.logger.info "------user.id=#{user.try(:id)}"
    unless current_user == user || is_admin?
      redirect_to register_path, alert: '很抱歉您没有权限操作!'
    end
  end

  def to_label_xml hash
    params_str = ''
    hash.each do |key, value|
      params_str += "<#{key}>" + "<![CDATA[#{value}]]>" + "</#{key}>"
    end
    params_xml = '<xml>' + params_str + '</xml>'
  end

  def random_str str_length
    arr = ('0'..'9').to_a + ('a'..'z').to_a
    nonce_str = ''
    str_length.times do
      nonce_str += arr[rand(36)]
    end
    nonce_str
  end

  def create_sign hash
    key = WX_API_KEY
    stringA = hash.select{|key, value|value.present?}.sort.map do |arr|
     arr.map(&:to_s).join('=')
   end
   stringA = stringA.join("&")
   string_sing_temp = stringA + "&key=#{key}"
   sign = (Digest::MD5.hexdigest string_sing_temp).upcase
 end

 def create_sign_for_js hash
  stringA = hash.select { |key, value| value.present? }.sort.map do |arr|
    arr.map(&:to_s).join('=')
  end
  stringA = stringA.join("&")
  sign = (Digest::SHA1.hexdigest stringA)
end



def get_jsapi_ticket
  wechat = Wechat.first
  return wechat.jsapi_ticket if wechat.jsapi_ticket_expires_at.to_i > Time.now.to_i && wechat.jsapi_ticket.present?
  access_token = get_jsapi_access_token
  get_url = 'https://api.weixin.qq.com/cgi-bin/ticket/getticket'
  res_data_json = RestClient.get get_url, {:params => {:access_token => access_token, :type => 'jsapi'}}
  res_data_hash = ActiveSupport::JSON.decode res_data_json
  if res_data_hash['errmsg'] == 'ok'
    jsapi_ticket = res_data_hash['ticket']
    jsapi_ticket_expires_at = Time.zone.now.to_i + res_data_hash['expires_in'].to_i
    wechat.update_attributes(:jsapi_ticket => jsapi_ticket, jsapi_ticket_expires_at: jsapi_ticket_expires_at)
  end
  jsapi_ticket
end

def get_jsapi_access_token
  wechat = Wechat.first
  return wechat.access_token if wechat.access_token_expires_at.to_i > Time.now.to_i
  get_url = 'https://api.weixin.qq.com/cgi-bin/token'
  res_data_json = RestClient.get get_url, {:params => {:appid => WX_APP_ID, :grant_type => 'client_credential', :secret => WX_APP_SECRET}}
  res_data_hash = ActiveSupport::JSON.decode res_data_json
  access_token = res_data_hash["access_token"]
  expires_at = Time.now.to_i + res_data_hash['expires_in'].to_i
  wechat.update_attributes(:access_token => access_token, :access_token_expires_at => expires_at)
  access_token
end

def send_info_preview_api info
  post_url = "https://api.weixin.qq.com/cgi-bin/message/mass/preview?access_token=#{get_jsapi_access_token}"
  openid = 'ofi15uFg_zOm57nmfwgL10SbZqq4'
  data = {touser: openid, text: {content: info}, msgtype: 'text'}.to_json
  RestClient.post post_url, data
end

def send_template_info_api openid, data, url = '', template_id = 'M9Mf27pbdTdTIxN_AfwbI3G_9mb5FlaydtsKwOZgSX4'
  post_url = "https://api.weixin.qq.com/cgi-bin/message/template/send?access_token=#{get_jsapi_access_token}"
  post_data = {touser: openid, template_id: template_id, data: data, url: url}.to_json
  Rails.logger.info post_data
  RestClient.post post_url, post_data
end

def share_config
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
  end
end
