#encoding:utf-8
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
end
