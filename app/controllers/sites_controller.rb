#encoding:utf-8
class SitesController < ApplicationController
  before_action :validate_user!

  before_action :set_site, only: [:edit, :update, :destroy]

  def new
    @site = Site.new
  end

  def create
    if params[:province] && params[:city] && params[:area]
      area = [ChinaCity.get(params[:province]), ChinaCity.get(params[:city]), ChinaCity.get(params[:area])].join('/')
      address = ChinaCity.get(params[:province]) + ChinaCity.get(params[:city]) + ChinaCity.get(params[:area])+ site_params[:address]
    end
    @site = Site.new(site_params)
    @site.address = address
    @site.area = area
    if @site.save


      return_url = session[:return_url]
      if return_url
        session[:return_url] = nil
        return redirect_to return_url
      end

      if params[:groupbuy_id]
        return redirect_to groupbuy_path(params[:groupbuy_id])
      end

      redirect_to sitees_path, notice: '地址添加成功'
    else
      render :new
    end
  end

  def show
    @site = Site.find(params[:id])
  end

  def edit()
  end

  def update
    if params[:province] && params[:city] && params[:area]
      area = [ChinaCity.get(params[:province]), ChinaCity.get(params[:city]), ChinaCity.get(params[:area])].join('/')
      address = ChinaCity.get(params[:province]) + ChinaCity.get(params[:city]) + ChinaCity.get(params[:area])+ site_params[:address]
    end
    if params[:from] == 'ajax'
      site = Site.where(default: 1)
      if site.present?
        site.first.update(default: 0)
      end
      Site.find(params[:id]).update(default: 1)
      return render text: 'success'
    end

    if @site.update(site_params)
      @site.update(address: address)
      @site.update(area: area)


      return_url = session[:return_url]

      if return_url
        session[:return_url] = nil
        return redirect_to return_url
      end
      redirect_to sitees_path(groupbuy_id: params[:groupbuy_id]), notice: '地址修改成功'
    else
      render :edit
    end
  end

  def destroy
   @site.destroy
   respond_to do |format|
    format.html {redirect_to sitees_path, notice: '地址删除成功'}
    format.js
  end
  end

  def index

    @sites = Site.all
    @site = Site.new
  end

  private
  def set_site
    @site = Site.find(params[:id])
  end

  def site_params
    params.require(:site).permit( :address,  :area)
  end
end
