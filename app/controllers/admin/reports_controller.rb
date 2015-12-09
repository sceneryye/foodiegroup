class Admin::ReportsController < ApplicationController
  before_action :autheorize_admin!
  layout 'admin'
  def index
    @users = User.paginate(per_page: 20, page: params[:page]).order(id: :asc)
    render layout: 'admin'
  end

  def users_list
    @users = User.paginate(per_page: 20, page: params[:page]).order(id: :asc)
  end

  def events_list
    @events = Event.paginate(per_page: 20, page: params[:page]).order(id: :asc)
  end

  def topics_list
    @topics = Topic.paginate(per_page: 20, page: params[:page]).order(id: :asc)
  end
end
