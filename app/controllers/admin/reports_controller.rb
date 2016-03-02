class Admin::ReportsController < ApplicationController
  before_action :autheorize_admin!
  layout 'admin'
  def index
    @users = User.paginate(per_page: 20, page: params[:page]).order(id: :asc)
  end

  def users_list
    @users = User.paginate(per_page: 20, page: params[:page]).order(id: :asc)
  end

  def groupbuys_list
    @groupbuys = Groupbuy.paginate(per_page: 20, page: params[:page]).order(id: :asc)
  end

  def topics_list
    @topics = Topic.paginate(per_page: 20, page: params[:page]).order(id: :asc)
  end

  def participants_list
    @groupbuy = Groupbuy.find(params[:groupbuy_id])
    @participants = Participant.unscoped {Participant.where(:groupbuy_id => params[:groupbuy_id]).paginate(per_page: 100, page: params[:page]).order(status_pay: :desc)}
  end

  def tags_list
    @tags = Tag.all.order(locale: :asc)
  end

  def set_online_offline
    @groupbuy = Groupbuy.find_by(id: params[:id])
    if params[:online] == 'true'
      @groupbuy.update(online: true)
    elsif params[:online] == 'false'
      @groupbuy.update(online: false)
    end
    render json: {online: @groupbuy.online.to_s}.to_json
  end
end
