#encoding:utf-8
class LogisticsController < ApplicationController
  before_action :validate_user!
  before_action only: [:show, :edit, :update, :destroy] do
    validate_permission!(set_logistic.user)
  end
  before_action :set_logistic, only: [:edit, :update, :destroy]

  def new
    @logistic = Logistic.new
  end

  def create
   
    @logistic = Logistic.new(logistic_params)
    @logistic.user = current_user

    if @logistic.save
      (1..6).each do |i|
        LogisticsItem.new do |item|
          item.logistic_id =  @logistic.id
          item.areas = params["item#{i}_area".to_sym]
          item.price = params["item#{i}_price".to_sym]
          item.each_add = params["item#{i}_each_add".to_sym]
        end.save
      end
      # if params[:default] == '1'
      #   logistic = Logistic.where(default: 1)
      #   if logistic.present?
      #     logistic.first.update(default: 0)
      #   end
      #   @logistic.update(default: 1)
      # end
      
      return_url = session[:return_url]
      if return_url
        session[:return_url] = nil
        return redirect_to return_url
      end

      if params[:groupbuy_id]
        return redirect_to groupbuy_path(params[:groupbuy_id])
      end

      redirect_to logistics_path, notice: t(:logistic_rule_save_successed)
    else
      render :new
    end
  end

  def show
    @logistic = Logistic.find(params[:id])
  end

  def edit()
  end

  def update
    if params[:province] && params[:city] && params[:area]
      area = [ChinaCity.get(params[:province]), ChinaCity.get(params[:city]), ChinaCity.get(params[:area])].join('/')
      address = ChinaCity.get(params[:province]) + ChinaCity.get(params[:city]) + ChinaCity.get(params[:area])+ logistic_params[:address]
    end
    if params[:from] == 'ajax'
      logistic = Logistic.where(default: 1)
      if logistic.present?
        logistic.first.update(default: 0)
      end
      Logistic.find(params[:id]).update(default: 1)
      return render text: 'success'
    end

    if @logistic.update(logistic_params)
      Rails.logger.info logistic_params
      if params[:default] == '1'
        logistic = Logistic.where(default: '1')
        if logistic.present?
          logistic.first.update(default: '0')
        end
        @logistic.update(default: '1')
      end

      return_url = session[:return_url]
      if return_url
        session[:return_url] = nil
        return redirect_to return_url
      end
      redirect_to logistics_path, notice: '地址修改成功'
    else
      render :edit
    end
  end

  def destroy
   @logistic.destroy
   respond_to do |format|
      format.html {redirect_to logistics_path, notice: '地址删除成功'}
      format.js
    end
  end

  def index
    if params[:groupbuy_id]
      session[:return_url]= new_groupbuy_participant_path(params[:groupbuy_id])
      params.delete(:groupbuy_id)
    end
    @logistics = current_user.logistics
    if @logistics.nil?
      redirect_to new_logistic_path
    end
  end

  def acquire_logistic_details
    id = params[:id]
    logistic = Logistic.find_by_id(id)
    title = logistic.name
    items = logistic.logistics_items
    contents = []
    items.each do |item|
      body = item.areas + ':' + item.price.to_s + '元/千克'
      contents << body
    end
    content = contents.join(';')
    render json: {title: title, content: content}.to_json
  end

  private
  def set_logistic
    @logistic = Logistic.find(params[:id])
  end

  def logistic_params
    params.require(:logistic).permit(:name, :default)
  end
end
