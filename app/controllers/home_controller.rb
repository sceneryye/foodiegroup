#encoding:utf-8
class HomeController < ApplicationController
	before_action {@forums = Forum.all}
  before_action :login_with_mobile

	def index
		#微信入口页面

		Rails.logger.info "---------------------------#{session[:openid]}"
    Rails.logger.info "---------------------------#{session[:mobile]}"
    Rails.logger.info "---------------------------#{current_user.try(:nickname)}"
    
		@events = Event.where("locale='#{session[:locale]}' and recommend > ?", 0).includes(:user)
		@groupbuys = Groupbuy.where("recommend>0").includes(:user)
		@tags = Tag.where(locale: session[:locale]).limit(10)
		@topics = Topic.where("forum_id = ? and recommend > ?", forum_id, 0).includes(:forum, :forum).order(recommend: :desc)


	end

  private
  def login_with_mobile
    if session[:mobile].present?
      user = User.find_by(mobile: session[:mobile])
      login user
    end
  end
end
