#encoding:utf-8
class ForumsController < ApplicationController
	before_action {@forums = Forum.all}
	before_action :validate_user!, only: [:new, :edit, :update, :create, :destroy]
	before_action :login_with_mobile

	def new
		@forum = Forum.new
	end

	def create
		@forum = Forum.new(params[:forum])

		if @forum.save
			redirect_to forum_url, notice: '论坛添加成功!'
		else
			render :new
		end
	end

	def edit() end

		def update

		end

		def destroy
		end

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

		@events = Event.where("locale='#{session[:locale]}' and recommend>0").includes(:user)
		@groupbuys = Groupbuy.where("locale='#{session[:locale]}' and recommend>0").includes(:user)
		@tags = Tag.where(locale: session[:locale]).limit(10)
		@topics = Topic.where(forum_id:forum_id).includes(:forum, :forum).first

	end

	def show
		@forum  = Forum.find(forum_id)
		@topics = @forum.topics.includes(:forum)
	end

	private
	def login_with_mobile
		if session[:mobile].present?
			user = User.find_by(mobile: session[:mobile])
			login user
		end
	end
end
