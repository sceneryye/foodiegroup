#encoding:utf-8
class SearchesController < ApplicationController

	def index

	end

	def create
    render 'index', locals: {page: search}
	end

	def show
    render 'index', locals: {page: search}
	end

	def tag

	end

	def user

	end

  private

  def search
    type = params[:type] || 'event'

    if params[:search]
      @keyword = q = params[:search][:keyword]
    else
      @keyword = q = params[:keyword]
    end

    if q.nil?
      return 
    end
    q = q.strip

    q = q.gsub(/[\s,\.\*\+\/\-:'"!\&\^\[\]\(\)， 。：”’（）%@！、]+/,"%")
    @splits = q.split(/%+/)

    case type 
      when 'topic'
        @splits.each do |key|
          @data = Topic.where("title like :key or body like :key",:key=>"%#{q}%")
        end
      when 'comment'
        @splits.each do |key|
          @data = Comment.where("body like :key",:key=>"%#{q}%")
        end       
      when 'user'
        @splits.each do |key|
          @data = User.where("name like :key or nickname like :key",:key=>"%#{q}%")
        end
      else
          type='event'
         @splits.each do |key|
          @data = Event.where("title like :key or body like :key",:key=>"%#{q}%")
        end
    end
  end

	

end