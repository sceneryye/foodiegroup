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

		@events = Event.includes(:user).first
	  	@tags = Tag.order("rate DESC").limit(10)
	    @topics = Topic.includes(:forum, :forum).first
	    
	    if signed_in?
	      @plus_menu = [{name: t(:add_event), path: new_event_path},
	      				@plus_menu = [{name: t(:add_topic), path: new_forum_topic_path(1)}]
	      			]
	    end

	end

	def show
	    @forum  = Forum.find(params[:id])
	    @topics = @forum.topics.includes(:forum)
	    if signed_in?
	    	 @plus_menu = [{name: t(:add_topic), path: new_forum_topic_path(@forum)}]
        end
	end
end
