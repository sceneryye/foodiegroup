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
      photo_ids = params[:photo_ids].split(',')
      Photo.where(id: photo_ids).update_all(topic_id: @topic.id)
      redirect_to topic_url(@topic), notice: '话题添加成功'
    else
      render :new
    end
  end

  def show
    @parent = @topic = Topic.includes(:forum, :comments, :user).find(params[:id])
    @active = @topic.comments.count > 10 ? true : false
    more = 10
    @comments = @topic.comments.includes(:user)[0...more]
    @comment = @topic.comments.new
    if signed_in?
     @plus_menu = [{name: t(:new_comment), path: new_topic_comment_path(@topic)}]
   end
 end

 def edit() end

  def update
    if params[:from] == 'admin_edit_recommend'
      topic = Topic.find(params[:id])
      if topic.update(recommend: params[:recommend])
        return render text: 'success'
      else
        return render text: 'false'
      end
    end
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

  def more_comments
    elements = []
    parent = params[:parent]
    start = params[:start].to_i
    over = params[:over].to_i
    comments = parent.capitalize.constantize.includes(:forum, :comments, :user).find(params[:id]).comments.includes(:user)[start...over]
    comments.each do |comment|
      elements << "<div class='row small-collapse'><div  class='columns small-12 comment'>" << comment.body.html_safe if comment.body << view_context.comment_info(comment) << "</div></div><hr />"
    end
    elements = elements.join
    return render text: elements
  end


  

  private
  def set_topic
    @topic = Topic.find(params[:id])
  end

  def topic_params
    params.require(:topic).permit(:title, :body)
  end
end
