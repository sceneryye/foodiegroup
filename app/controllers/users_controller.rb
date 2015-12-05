#encoding:utf-8
class UsersController < ApplicationController
  before_action :select_user, only: [:show, :edit, :update, :destroy]
  before_action only: [:edit, :update, :destroy] do
    validate_permission! select_user
  end

  def new
    @user = User.new
    @groups = Group.all
  end

  def create
    if user_params[:password].nil?
      user_params[:password] = user_params[:mobile]
    end
    @user = User.new(user_params)
    @user.weixin_openid = session[:openid]
    @user.avatar = session[:avatar]    
    @user.nickname = session[:nickname]

    if @user.save
      login(@user)
      redirect_to root_url, notice: '注册成功!'
    else
      render :new
    end
  end

  def show
    type = params[:type] || '话题'

    case type 
    when '话题'
      @user = User.includes(:topics).find_by_username(params[:id])
      if @user
        @data = @user.topics.includes(:forum)
      end
    when '评论'
      @user = User.includes(:comments).find_by_username(params[:id])
      @data = @user.comments.includes(:topic)
      #@data = @user.comments.includes(:events)
    when '活动'
      @user = User.includes(:events).find_by_username(params[:id])
      @data = @user.events
     when '参与'
      @user = User.includes(:participants).find_by_username(params[:id])
      @data = @user.participants.includes(:event)
    end

    render layout: "profile", locals: {page: type}
  end

  def edit
    render layout: "profile"
  end

  def update
    uploaded_io = params[:file]

    if !uploaded_io.blank?
      extension = uploaded_io.original_filename.split('.')
      filename = "#{Time.now.strftime('%Y%m%d%H%M%S')}.#{extension[-1]}"
     # filepath = "#{PIC_PATH}/teachResources/devices/#{filename}"
      filepath = "#{PIC_PATH}/avatars/#{filename}"
      File.open(filepath, 'wb') do |file|
        file.write(uploaded_io.read)
      end
      user_params.merge!(:avatar=>"/avatars/#{filename}")
    end

    update_params = user_params

    if update_params.has_key?(:password)
      update_params.delete([:password, :password_confirmation])
    end

    if @user.update(update_params)
      redirect_to profile_url(@user), notice: '个人信息修改成功'
    else
      render :edit, layout: "profile"
    end
  end

  def destroy
    logout
    @user.destroy
    redirect_to root_url
  end

  private

  def user_params
    params.require(:user).permit!
  end

  def select_user
    @user = User.find_by_username(params[:id])
  end
end
