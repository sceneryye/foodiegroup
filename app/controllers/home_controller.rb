#encoding:utf-8
class HomeController < ApplicationController
	before_action {@forums = Forum.all}

	def index
		#微信入口页面

		if !params[:openid].blank?
			session[:openid] = params[:openid].split('_shop')[0]

			session[:avatar] = params[:avatar]
			session[:nickname] = params[:nickname]
			user = User.where(:weixin_openid=>session[:openid])
			Rails.logger.info "#################{current_user.nickname}###################{session[:nickname]}"
			if user.size>0				
				@user = user.first do |u|
					u.avatar = session[:avatar]
					u.nickname = session[:nickname]
				end.save

				login user.first
				redirect_to root_path #清空传过来的参数
			else
				redirect_to  register_path
			end
		end
		Rails.logger.info "#################{profile_path(current_user.nickname)}###################{session[:nickname]}"
		if current_user.nil?
			session[:locale] = 'zh'
		end
		@events = Event.where("locale='#{session[:locale]}'").includes(:user)
		@groupbuys = Groupbuy.where("locale='#{session[:locale]}' and recommend>0").includes(:user)
		@tags = Tag.where(locale: session[:locale]).limit(10)
		@topics = Topic.where("forum_id = ? and recommend > ?", forum_id, 0).includes(:forum, :forum).order(recommend: :desc)


	end
end
