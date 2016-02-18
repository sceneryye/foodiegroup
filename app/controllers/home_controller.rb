#encoding:utf-8
class HomeController < ApplicationController
	before_action {@forums = Forum.all}

	def index
		#微信入口页面

		Rails.logger.info "---------------------------#{session[:openid]}"
    Rails.logger.info "---------------------------#{session[:mobile]}"
    Rails.logger.info "---------------------------#{current_user.try(:nickname)}"
    if params[:openid]
      session[:openid] = params[:openid]
      session[:avatar] = params[:avatar]
      session[:nickname] = params[:nickname]
      user = User.where(:weixin_openid=>session[:openid])
      if user.size>0
        @user = user.first do |u|
          u.avatar = session[:avatar]
          u.nickname = session[:nickname]
        end.save

        login user.first
        redirect_to root_path
      else
        redirect_to register_path
      end
    end
		@events = Event.where("locale='#{session[:locale]}' and recommend > ?", 0).includes(:user)
		@groupbuys = Groupbuy.where("recommend>0").includes(:user)
		@tags = Tag.where(locale: session[:locale]).limit(10)
		@topics = Topic.where("forum_id = ? and recommend > ?", forum_id, 0).includes(:forum, :forum).order(recommend: :desc)


	end
end
