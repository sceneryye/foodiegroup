#encoding:utf-8
require 'rest-client'
require 'open-uri'
class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_username(params[:session][:user_name])

    if user && user.authenticate(params[:session][:password])
      login(user)
      redirect_to root_url, notice: '登录成功'
    else        
      flash[:error] = "账户名或密码错误"      
      redirect_to login_url
    end
  end

  def destroy
    logout
    redirect_to root_url, notice: '退出登录'
  end

  def auto_login
    state = rand(30000).to_s.ljust(5, '0')
    redirect_url = CGI.escape 'http://vshop.trade-v.com/foodiegroup/sessions/callback'
    url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{WX_APP_ID}&redirect_uri=#{redirect_url}&response_type=code&scope=snsapi_userinfo&state=#{state}#wechat_redirect"
    redirect_to url
  end

  def callback
    code = params[:code]
    now = Time.zone.now.to_i
    if Wechat.first.nil?
      data = get_auth_access_token code
      Rails.logger.info data
    end
    if now < Wechat.first.auth_refresh_token_expires_at.to_i - 100
      data = refresh_auth_access_token
      access_token = data[:access_token]
      openid = data[:openid]
    else
      data = get_auth_access_token code
      access_token = data[:access_token]
      openid = data[:openid]
    end
    if user = User.find_by(weixin_openid: openid)
      login user
      redirect_to root_path
    else
      data = get_user_info(openid)
      session[:openid] = data[:openid]
      session[:avatar] = data[:headimgurl]
      session[:nickname] = data[:nickname]
      redirect_to register_path
    end
  end

  private

  def get_auth_access_token code
    get_url = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=#{WX_APP_ID}&secret=#{WX_APP_SECRET}&code=#{code}&grant_type=authorization_code"
    res_data_json = RestClient.get get_url
    res_data_hash = ActiveSupport::JSON.decode res_data_json
    Rails.logger.info res_data_hash
    access_expires_at = Time.zone.now.to_i + res_data_hash[:expires_in]
    refresh_expires_at = Time.zone.now.to_i + 24 * 3600 * 7
    wechat = Wechat.first 
    if wechat && Wechat.first.auth_access_token.present?

      wechat.update(auth_access_token: res_data_hash[:access_token], auth_refresh_token_expires_at: access_expires_at, auth_refresh_token_expires_at: refresh_expires_at, auth_refresh_token: res_data_hash[:refresh_token])
    else
      wechat = Wechat.new(auth_access_token: res_data_hash[:access_token], auth_refresh_token_expires_at: access_expires_at, auth_refresh_token_expires_at: refresh_expires_at, auth_refresh_token: res_data_hash[:refresh_token])
      wechat.save
    end
    
    res_data_hash
  end

  def refresh_auth_access_token
    refresh_token = Wechat.first.auth_refresh_token
    get_url = "https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=#{WX_APP_ID}&grant_type=refresh_token&refresh_token=#{refresh_token}"
    res_data_json = RestClient.get get_url
    res_data_hash = ActiveSupport::JSON.decode res_data_json
    Wechat.first.update(auth_access_token: res_data_hash[:access_token], auth_refresh_token_expires_at: access_expires_at)
    res_data_hash
  end

  def get_user_info openid
    access_token = Wechat.first.auth_access_token
    get_url = "https://api.weixin.qq.com/sns/userinfo?access_token=#{access_token}&openid=#{openid}&lang=zh_CN"
    res_data_json = RestClient.get get_url
    res_data_hash = ActiveSupport::JSON.decode res_data_json
  end
end
