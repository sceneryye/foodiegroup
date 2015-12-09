#encoding:utf-8
class ApplicationController < ActionController::Base
  include SessionsHelper
  protect_from_forgery with: :exception
  helper_method :signed_in?, :current_user

  before_action :set_locale


  private

  def set_locale
    # 可以將 ["en", "zh-TW"] 設定為 VALID_LANG 放到 config/environment.rb 中
    if params[:locale] && I18n.available_locales.include?( params[:locale].to_sym )
      session[:locale] = params[:locale]
    end

    I18n.locale = session[:locale] || I18n.default_locale
  end

  def login(user)
    session[:user_id] = user.id
    if user.group.name =='Foodie Group Buying Group'
      session[:locale]='en'
    else
      session[:locale]='zh'
    end
    
  end

  def logout
    session[:user_id] = nil
  end

  def current_user
    @current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
    #@current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def signed_in?
    current_user
  end

  def validate_user!
    unless signed_in?
      redirect_to login_url, alert: '请先登录！'
    end
  end

  def validate_permission!(user)
    unless current_user == user || is_admin?
      redirect_to root_url, alert: '很抱歉您没有权限操作!'
    end
  end
end
