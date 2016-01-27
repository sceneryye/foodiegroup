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
    if params[:province] && params[:city] && params[:area]
      area = [ChinaCity.get(params[:province]), ChinaCity.get(params[:city]), ChinaCity.get(params[:area])].join('/')
      address = ChinaCity.get(params[:province]) + ChinaCity.get(params[:city]) + ChinaCity.get(params[:area])+ logistic_params[:address]
    end
    @logistic = Logistic.new(logistic_params)
    @logistic.address = address
    @logistic.area = area
    @logistic.user = current_user
    Rails.logger.info logistic_params
    if@logistic.save
      if params[:default] == '1'
        logistic = Logistic.where(default: 1)
        if logistic.present?
          logistic.first.update(default: 0)
        end
        @logistic.update(default: 1)
      end
      
      return_url = session[:return_url]
      if return_url
        session[:return_url] = nil
        return redirect_to return_url
      end

      if params[:groupbuy_id]
        return redirect_to groupbuy_path(params[:groupbuy_id])
      end

      redirect_to logistics_path, notice: '地址添加成功'
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
      @logistic.update(address: address)
      @logistic.update(area: area)
      Rails.logger.info logistic_params
      if params[:default] == '1'
        logistic = Logistic.where(default: 1)
        if logistic.present?
          logistic.first.update(default: 0)
        end
        @logistic.update(default: 1)
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
  @logistic = Logistic.new
end

private
def set_logistic
  @logistic = Logistic.find(params[:id])
end

def logistic_params
  params.require(:logistic).permit(:name, :address, :mobile, :area, :default)
end
end
