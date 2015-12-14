class Admin::ReportsController < ApplicationController
  before_action :autheorize_admin!
  layout 'admin'
  def index
    @users = User.paginate(per_page: 20, page: params[:page]).order(id: :asc)
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

  def participants_list
    @event = Event.find(params[:event_id])
    @participants = Participant.unscoped {Participant.where(:event_id => params[:event_id]).order(status_pay: :desc)}
  end
end
