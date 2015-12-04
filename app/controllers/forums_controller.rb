#encoding:utf-8
class ForumsController < ApplicationController
  before_action {@forums = Forum.all}


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
			user = User.where(:weixin_openid=>session[:openid])
			if user.size>0
				login user.first
				redirect_to '/' #清空传过来的参数
			else
				redirect_to '/register'
			end
		end


		@events = Event.includes(:user)
	  	@tags = Tag.order("rate DESC").limit(10)
	    @topics = Topic.includes(:forum, :forum)
	end

	def show
	    @forum  = Forum.find(params[:id])
	    @topics = @forum.topics.includes(:forum)
	end
end
