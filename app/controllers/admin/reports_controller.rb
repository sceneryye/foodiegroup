class Admin::ReportsController < ApplicationController
  before_action :autheorize_admin!
  def index
    @user = User.all.paginate(per_page: 20, page: params[:page]).order(id: :asc)
  end
end
