#encoding:utf-8
class TopicsController < ApplicationController
  before_action :validate_user!, except: [:show]
  before_action only: [:edit, :update, :destroy] do
    validate_permission!(set_topic.user)
  end
  before_action :set_topic, only: [:edit, :update, :destroy]
  before_action only: [:new, :create] {@forum = Forum.find(params[:forum_id])}

  def new
    @topic = @forum.topics.new
  end

  def create
    @topic = @forum.topics.new(topic_params)
    @topic.user = current_user

    if @topic.save
      redirect_to topic_url(@topic), notice: '话题添加成功'
    else
      render :new
    end
  end

  def show
    @topic = Topic.includes(:forum, :comments, :user).find(params[:id])
    @comments = @topic.comments.includes(:user)
    if signed_in?
     @plus_menu = [{name: t(:new_comment), path: new_topic_comment_path(@topic)}]
   end
 end

 def edit() end

  def update
    if @topic.update(topic_params)
      redirect_to topic_url(@topic), notice: '话题修改成功'
    else
      render :edit
    end
  end

  def destroy
    @topic.destroy
    respond_to do |format|
      format.html {redirect_to root_url, notice: '话题删除成功'}
      format.js
    end
    
  end

  private
  def set_topic
    @topic = Topic.find(params[:id])
  end

  def topic_params
    params.require(:topic).permit(:title, :body)
  end
end
