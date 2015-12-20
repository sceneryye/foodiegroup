#encoding:utf-8
class CommentsController < ApplicationController
  before_action :validate_user!
  before_action only: [:edit, :update, :destroy] do
    validate_permission!(select_comment.user)
  end
  before_action :select_comment, only: [:edit, :update, :destroy]
  before_action only: [:new, :create,:index] {
     if params[:topic_id]
      @parent = Topic.find(params[:topic_id])
    elsif params[:event_id]
      @parent = Event.find(params[:event_id])
    elsif params[:groupbuy_id]
      @parent = Groupbuy.find(params[:groupbuy_id])
    end
  }

  def new
    @comment = @parent.comments.new    
  end

  def create  

    @comment = @parent.comments.new(comment_params)
    @comment.user = current_user

    if @comment.save
      if params[:topic_id]
        redirect_to topic_url(@parent), notice: '添加评论成功'
      else
        redirect_to event_url(@parent), notice: '添加评论成功'
      end
    else
      render :new
    end
  end

  def edit() end

  def update
    if @comment.update(comment_params)
       if @comment.topic
        redirect_to topic_url(@comment.topic), notice: '更新评论成功'
      elsif @comment.event
        redirect_to event_url(@comment.event), notice: '更新评论成功'
      end
    else
      render :edit
    end
  end

  def destroy

    @comment.destroy
    if @comment.topic
      redirect_to topic_url(@comment.topic), notice: '删除评论成功'
    elsif @comment.event
       redirect_to event_url(@comment.event), notice: '删除评论成功'
    end

  end

  def index
    @comment = @parent.comments.new
    @comments = @parent.comments.includes(:user)
  end

  private

  def select_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
