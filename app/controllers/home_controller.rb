#encoding:utf-8
class HomeController < ApplicationController
	before_action {@forums = Forum.all}

	def index
		#微信入口页面
		if params[:openid]
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
				redirect_to '/' #清空传过来的参数
			else
				redirect_to '/register'
			end
		end

		if current_user.nil?
			session[:locale] = 'zh'
		end
		@events = Event.where("locale='#{session[:locale]}'").includes(:user)
		@groupbuys = Groupbuy.where("locale='#{session[:locale]}' and recommend>0").includes(:user)
		@tags = Tag.where(locale: session[:locale]).limit(10)
		@topics = Topic.where(forum_id:forum_id).includes(:forum, :forum)


	end
end
