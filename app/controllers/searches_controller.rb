#encoding:utf-8
class SearchesController < ApplicationController

	def index

	end

	def create
		type = params[:type] || 'topic'

    @keyword = q = params[:search][:keyword].strip
    q = q.gsub(/[\s,\.\*\+\/\-:'"!\&\^\[\]\(\)， 。：”’（）%@！、]+/,"%")
    @splits = q.split(/%+/)


    case type 
    when 'topic'
      @splits.each do |key|
        @data = Topic.where("title like :key or body like :key",:key=>"%#{key}%")
      end
    when 'comment'
      @splits.each do |key|
        @data = Comment.where("body like :key",:key=>"%#{key}%")
      end
    when 'event'
      @splits.each do |key|
        @data = Event.where("title like :key or body like :key",:key=>"%#{key}%")
      end
     when 'user'
      @splits.each do |key|
        @data = User.where("name like :key or nickname like :key",:key=>"%#{key}%")
      end
    end
    render 'index', locals: {page: type}
	end

	def show

    type = params[:type] || 'topic'

    @keyword = params[:keyword]
    if @keyowrd
      q = @keyword.strip
      q = q.gsub(/[\s,\.\*\+\/\-:'"!\&\^\[\]\(\)， 。：”’（）%@！、]+/,"%")
      @splits = q.split(/%+/)


      case type 
      when 'topic'
        @splits.each do |key|
          @data = Topic.where("title like :key or body like :key",:key=>"%#{key}%")
        end
      when 'comment'
        @splits.each do |key|
          @data = Comment.where("body like :key",:key=>"%#{key}%")
        end
      when 'event'
        @splits.each do |key|
          @data = Event.where("title like :key or body like :key",:key=>"%#{key}%")
        end
       when 'user'
        @splits.each do |key|
          @data = User.where("name like :key or nickname like :key",:key=>"%#{key}%")
        end
      end
    end
    render 'index', locals: {page: type}


	end
	def tag

	end

	def user

	end

	

end