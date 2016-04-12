#encoding:utf-8
require 'rest-client'
require 'open-uri'
class SessionsController < ApplicationController
  def new
    if signed_in?
      return redirect_to profile_path(current_user)
    end
  end

  def create
    user = User.find_by(username: params[:session][:user_name])

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
    session[:return_url] = params[:return_url]
    state = rand(30000).to_s.ljust(5, '0')
    redirect_url = CGI.escape 'http://foodie.trade-v.com/sessions/callback?return_url=' + params[:return_url]
    url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{WX_APP_ID}&redirect_uri=#{redirect_url}&response_type=code&scope=snsapi_userinfo&state=#{state}#wechat_redirect"
    redirect_to url
  end

  def callback
    return_url = session[:return_url] || params[:return_url]
    session.delete(:return_url)
    code = params[:code]
    now = Time.zone.now.to_i
    
    data = get_auth_access_token code
    access_token = data["access_token"]
    openid = data["openid"]
    user = User.find_by(weixin_openid: openid)
    Rails.logger.info "----openid=#{openid}"
    Rails.logger.info "----return_url=#{return_url}"
    if user && openid.present? && user.nickname.present? && user.avatar.present?
      begin
        RestClient.get user.avatar
      rescue
        data = get_user_info(openid, access_token)
        user.update_column :avatar, data['headimgurl']
        Rails.logger.info "------------update avatar => #{user.avatar}"
        Rails.logger.info "------------data => #{data}"
        login user
        return redirect_to return_url || root_path
      end
      login user
      return redirect_to return_url || root_path
      
    #elsif return_url.split('?').first.in? ['http://foodie.trade-v.com/register', 'http://foodie.trade-v.com/login']
     # data = get_user_info(openid, access_token)
      #session[:openid] = data["openid"]
      # session[:avatar] = data["headimgurl"]
      # session[:nickname] = data["nickname"]
      # Rails.logger.info "---------------#{data}"
      # Rails.logger.info "---------------#{session[:openid]}"
      # Rails.logger.info "---------------#{session[:nickname]}"
      # Rails.logger.info "---------------return_url=#{return_url}"
      # redirect_to register_path
    # else
      # data = get_user_info(openid, access_token)
      # session[:openid] = data["openid"]
      # session[:avatar] = data["headimgurl"]
      # session[:nickname] = data["nickname"]
    else
      data = get_user_info(openid, access_token)
      Rails.logger.info "---------------data => #{data}"
      Rails.logger.info "---------------nickname => #{user.nickname}"
      Rails.logger.info "---------------user_id => #{user.id}"
      if user && openid.present? && (user.nickname.nil? || user.avatar.nil?)
        user.update_columns nickname: data['nickname'], avatar: data['headimgurl'], username: data['nickname']
        Rails.logger.info "---------------nickname_after_update => #{user.nickname}"
        Rails.logger.info "---------------user_id_after_update => #{user.id}"
        login user
        return redirect_to return_url || root_path
      else
        new_user = User.new weixin_openid: data["openid"], avatar: data["headimgurl"], nickname: data["nickname"], username: data["nickname"], password: data["openid"]
        if new_user.save
          login new_user
          return redirect_to return_url || root_path
        else
          return redirect_to root_path(errmsg: 'Failed to create new user.')
        end
      end
    end
  end

  private

  def get_auth_access_token code
    get_url = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=#{WX_APP_ID}&secret=#{WX_APP_SECRET}&code=#{code}&grant_type=authorization_code"
    res_data_json = RestClient.get get_url
    res_data_hash = ActiveSupport::JSON.decode res_data_json
    Rails.logger.info res_data_hash
    res_data_hash
  end

  def refresh_auth_access_token
    refresh_token = Wechat.first.auth_refresh_token

    get_url = "https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=#{WX_APP_ID}&grant_type=refresh_token&refresh_token=#{refresh_token}"
    res_data_json = RestClient.get get_url
    res_data_hash = ActiveSupport::JSON.decode res_data_json
    access_expires_at = Time.zone.now.to_i + res_data_hash["expires_in"].to_i
    Wechat.first.update(auth_access_token: res_data_hash["access_token"], auth_access_token_expires_at: access_expires_at)
    res_data_hash
  end

  def get_user_info openid, access_token
    get_url = "https://api.weixin.qq.com/sns/userinfo?access_token=#{access_token}&openid=#{openid}&lang=zh_CN"
    res_data_json = RestClient.get get_url
    res_data_hash = ActiveSupport::JSON.decode res_data_json
  end
end
